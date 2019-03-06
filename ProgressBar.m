classdef ProgressBar < handle
    properties
        N = 1;
        index = 0;
        time_remaining = NaN;
        elapsed_time = 0;
        as_text = false;
        as_waitbar = true;        
        msg = '';
        Tag = 'ProgressBarObject';

    end
    properties (Hidden=true)
        buffer_size = 0;        
        min_buffer = 1;
        buffer = [0];
        waitbar_handle = NaN;
        start_time = NaN;
        last_time = 0;
        last_msg = '';
    end
    methods
        function self = ProgressBar(N, varargin)
            %PROGRESSBAR Interactive Progress Bar
            % obj = PROGRESSBAR(N, varargin)
            %
            %PROGRESSBAR creates a text or graphical progress bar, which is
            % updated by calling the next() method.
            %
            %PROGRESSBAR(N, 'p1', v1, ...) sets the properties of
            % the objec.
            %
            %INPUT PROPERTIES:
            %   char msg: the string to be displayed
            %   boolean as_text: show a text based progress bar
            %   boolean as_waitbar: show a graphical waitbar
            %
            %QUERYABLE PROPERTIES:
            %   double time_remaining: the number of seconds until the loop
            %    is expected to finish
            %   double elapsed_time: the amount of time elapsed in seconds
            %   int index: the current index
            %   int N: the total number of loops
            %
            %
            %METHODS:
            %   obj.reset - reset the counter and restart the clock
            %   obj.next - increment the counter and update the display
            %   obj.close - close the progress bar 
            %
            
            self.N = N;
            self = setprops(self, varargin);
        end
        function reset(self)
            % Resets the Progress bar and restarts the clock
            % Called automatically by next() when index == 0
            if self.buffer_size > 0
                self.buffer = nan(self.buffer_size,1);
            end
            self.start_time = tic;
            self.index = 1;
            self.last_time = 0;
            self.elapsed_time = 0;
            self.update;
        end

        function next(self)
            % Increment the index and update the display. This should be
            % called at the *beginning* of each loop. 
            if self.index == 0
                self.reset
            else
                new_time = toc(self.start_time);
                if self.buffer_size > 0
                    self.buffer(mod(self.index-1,self.buffer_size)+1) = new_time-self.last_time;
                end
                self.index = self.index+1;
                self.last_time = new_time;
                if self.index > self.N
                    self.close
                else
                    self.update;
                end
            end
        end
        function close(self)
            % Closes the progress bar
            if ishandle(self.waitbar_handle)
                close(self.waitbar_handle)
            end
            if self.as_text
                fprintf('\n')
            end
        end
    function update(self)
        % Update the display of the progress bar
            self.elapsed_time = toc(self.start_time);
            self.time_remaining = self.estimate_remaining_time;
            new_msg = self.get_msg;
            if self.as_waitbar
                if ~ishandle(self.waitbar_handle)
                    self.waitbar_handle = waitbar(self.index/self.N,new_msg,'Tag','ProgressBar');
                else
                    waitbar(self.index/self.N,self.waitbar_handle,new_msg);
                end
            else
                if ishandle(self.waitbar_handle)
                    close(self.waitbar_handle)
                end
            end
            if self.as_text
                fprintf([repmat('\b',1,length(self.last_msg)),'%s'],new_msg);            
                self.last_msg = new_msg;               
            end
        end
    end

    methods (Hidden = true)
        function msg = get_msg(self)
            msg = sprintf('%s [%d/%d] %s/%s', self.msg, self.index,...
                self.N, self.time2clock(self.elapsed_time),...
                self.time2clock(self.time_remaining+self.elapsed_time));
        end
        function t_avg = time_per_inc(self)
            if self.index <= self.min_buffer
                t_avg = NaN;
            else
                if self.buffer_size > 0
                    t_avg = nanmean(self.buffer);
                else
                    t_avg = self.elapsed_time / (self.index - 1);
                end
            end
        end
        function t_remain = estimate_remaining_time(self)
            t_avg = self.time_per_inc;
            t_remain = (self.N-(self.index-1)) * t_avg;
        end
        
    end
    methods (Static)
        function clockstr = time2clock(time)
            if isnan(time)
                clockstr = '--:--';
            else
                seconds = mod(round(time),60);
                minutes = round((round(time)-seconds)/60);
                clockstr = sprintf('%02.0f:%02.0f',minutes,seconds);
            end
        end
    end
    
end