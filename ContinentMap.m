classdef ContinentMap
%ContinentMap defines, generates and plots a grid resembling a Continent 
    
    properties (Constant)
        
        CELL_TYPE_WATER = uint8(0);
        
        CELL_TYPE_LAND = uint8(1);
        
    end
        
    properties
        
        grid = []
        
        continentid = 0
        
        num_x = 0
        
        num_y = 0
                
    end

    methods (Static)
        
        %%
        function obj = generate(numCells, minX, maxX, minY, maxY, pwalk, nwalkmax)

            gridAdj = fix(sqrt(numCells));
            if gridAdj / 2 ~= fix(gridAdj/2)
                gridAdj = gridAdj + 1;
            end
            
            if nargin < 3
                minX = -gridAdj;
            end
            if nargin < 4
                maxX = gridAdj;
            end
            if nargin < 5
                minY = -gridAdj;
            end
            if nargin < 6
                maxY = gridAdj;
            end
                
            k = 2;

            numGridX = maxX - minX;
            numGridY = maxY - minY;
            
            offset = max([numGridX, numGridY])/2;
            
            if (offset/2~=fix(offset/2))
                offset=offset+1;
                
            end
            
            used = false(numGridX, numGridY);
            
            sz = size(used);

            tfIndAvail = false(numCells,1);

            used(offset+1, offset+1) = 1;
            
            num_neighbors = zeros(size(used));
          
            nwalk = randi([1 nwalkmax], 1);
            
            last = zeros(nwalk, 1);
            last(1) = sub2ind(sz, offset+1, offset+1);
    
            go = [ 1, 0 ; ...
                  -1, 0 ; ...
                   0, 1 ; ...
                   0, -1 ; ...
               ];
                       
            while k <= numCells
                
                if k == 2
                    ix = last(1);

                else
                    if rand(1) < pwalk
                        linIndAvail = find(tfIndAvail);
                        % select any one existing block
                        ix = randi([1 length(linIndAvail)], 1);
                        ix = linIndAvail(ix);
                        
                    else
                        if k > nwalk + 1 && nwalk > 1 && any(tfIndAvail(last))
                            available = last(tfIndAvail(last));
                            ixr = randi([1 length(available)], 1);
                            ix = available(ixr);
                            
                        else
                            % use the last generated block
                            ix = last(1);
                            
                        end

                    end
                    
                end

                [r, c] = ind2sub(sz, ix);
                r_off = r - offset;
                c_off = c - offset;

                block = [r_off, c_off];
                
                u_avail = r+1 < maxX+offset && ~used(r+1, c);
                d_avail = r-1 > 0 && ~used(r-1, c);
                r_avail = c+1 < maxY+offset && ~used(r, c+1);
                l_avail = c-1 > 0 && ~used(r, c-1);

                avail = find([u_avail d_avail r_avail l_avail]);
                
                if isempty(avail)
                    continue
                end
                
                ixr = randi([1 length(avail)], 1);
                
                b = avail(ixr);
                
                move = go(b,:);

                new_block = block + move;
                
                r_new = new_block(1) + offset;
                c_new = new_block(2) + offset;
                new_lin = sub2ind(sz, r_new, c_new);
                
                if nwalk > 1
                    last(2:nwalk) = last(1:nwalk-1);
                end
                
                last(1) = new_lin;

                % old block now has one new neighbor
                num_neighbors(r,c) = num_neighbors(r,c) + 1;
                
                % how many neighbors does the new block have?
                count = 0;
                if r_new-1 > 0 && used(r_new - 1, c_new)
                    count=count+1;
                    if b~=1
                        num_neighbors(r_new-1,c_new)=num_neighbors(r_new-1,c_new)+1;
                    end
                end
                if c_new-1 > 0 && used(r_new, c_new-1)
                    count=count+1;
                    if b~=3
                        num_neighbors(r_new,c_new-1)=num_neighbors(r_new,c_new-1)+1;
                    end
                end
                if c_new+1 <= maxY && used(r_new, c_new+1)
                    count=count+1;
                    if b~=4
                        num_neighbors(r_new,c_new+1)=num_neighbors(r_new,c_new+1)+1;
                    end
                end 
                if r_new+1 <= maxX && used(r_new+1, c_new)
                    count=count+1;
                    if b~=2
                        num_neighbors(r_new+1,c_new)=num_neighbors(r_new+1,c_new)+1;
                    end
                end                     
                
                num_neighbors(r_new,c_new) = count;

                used(r_new,c_new) = true;
                
                check = [ ...
                    r_new, c_new        ; ...
                    r_new, c_new+1      ; ...
                    r_new, c_new-1      ; ...
                    r_new+1, c_new      ; ...
                    r_new-1, c_new      ; ...
                    ];
                
                ixRM = check(:,1) < 1 | check(:,1) > maxX+offset | check(:,2) < 1 | check(:,2) > maxY+offset;
                check(ixRM, :) = [];
                
                check = sub2ind(sz, check(:,1), check(:,2));
                
                avail_tf = used(check) & num_neighbors(check) < 4;
                
                tfIndAvail(check(avail_tf)) = true;
                tfIndAvail(check(~avail_tf)) = false;
                                                
                k = k + 1;

            end % while
            
            
            [r, c] = find(used);

            x = r - offset;
            y = c - offset;
            
            CENTER_X = numGridX / 2;
            CENTER_Y = numGridY / 2;

            % CENTER_X and CENTER_Y correspond to point (1,1)

            % start with water, and fill in land over it
            grid_data = repmat(ContinentMap.CELL_TYPE_WATER, 1, numGridX * numGridY);
            sz = [numGridX, numGridY];
            
            r = x + CENTER_X + 1;
            c = y + CENTER_Y + 1;
            ix = sub2ind(sz, r, c);
            grid_data(ix) = ContinentMap.CELL_TYPE_LAND;

            obj = ContinentMap();
            obj.grid = grid_data;
            
            obj.num_x = numGridX;
            obj.num_y = numGridY;
            
        end % function
        
    end % Static methods



    methods

        
        %%
        function obj = ContinentMap(varargin)
            
        end
        
        

        %%
        function numCells = getNumCells(obj)
        
            numCells = obj.getNumX() * obj.getNumY();
            
        end
                
        
        %%
        function tf = isLand(obj)
            
            tf = obj.grid == ContinentMap.CELL_TYPE_LAND;
            
        end
        
        
        %%
        function tf = isWater(obj)
            
            tf = obj.grid == ContinentMap.CELL_TYPE_WATER;
            
        end       
        
        
        %%
        function x = getNumX(obj)
        
            x = obj.num_x;
            
        end        
        
        
        %%
        function y = getNumY(obj)
            
            y = obj.num_y;

            
        end % function
        

        %%
        function plot(obj)
            
            gridSize = [obj.num_x, obj.num_y];
            
            figure;
            pcolor(reshape(double(obj.grid), gridSize));
            
        end
        
    end % methods
    
end
