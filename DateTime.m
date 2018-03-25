classdef DateTime
    % Date and Time utility functions
    
    methods (Access=public, Static)
        
        function dnum = epoch2datenum(epoch)
            % Accepts a time value in UNIX Epoch Time and returns it as a 
            % datenum.
            % See also: datenum, datevec
            dnum = datenum(1970, 1, 1, 0, 0, epoch);
        end
        
        function [epoch_day, sec_since_mid] = epochparts(epoch_in)
            % EPOCHPARTS - splits a UNIX Epoch Time value into two parts:
            %   epoch_day - epoch time of the day
            %   sec_since_mid - seconds into the day (since midnight)

            % split input time into parts
            [Y, M, D, H, MN, S] = datevec(DateTime.epoch2datenum(epoch_in));
            
            % re-join the day parts together, and convert back to epoch
            dnum_day = datenum(Y,M,D);
            epoch_day = DateTime.datenum2epoch(dnum_day);
            
            sec_since_mid = H*3600 + MN*60 + S;
        end
        
        function epoch = datenum2epoch(dnum)
            % Converts a MATLAB datenum to a time since the Unix Epoch.
            epoch = (dnum - datenum(1970,1,1)) * 86400;
        end
        
        function str = epoch2datestr(epoch, varargin)
            % Accepts UNIX Epoch time, and returns that value as a date 
            % string.
            % The varagin input is passed directly to datestr()
            % See also: datestr, DateTime.epoch2datenum
            % Example with default formatting:
            % DateTime.epoch2datestr(1361287034)
            % ans =
            % 19-Feb-2013 15:17:14
            % Example with modified formatting:
            % DateTime.epoch2datestr(1361287034,21)
            % ans =
            % Feb.19,2013 15:17:14
            
            % Unix Epoch time -> MATLAB datenum
            dnum = DateTime.epoch2datenum(epoch);
            % MATLAB datenum -> string
            str = datestr(dnum,varargin{:});
        end
   
    end
    
end
