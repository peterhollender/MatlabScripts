classdef ProgressBar < handle
    properties
        N = 1;
        index = 0;
        time_remaining = NaN;
        elapsed_time = 0;
        as_text = false;
        as_waitbar = true;
    end
    properties (Hidden=true)
        msg = '';
        buffer = [0];
        min_buffer = 1;
        buffer_size = 0;
        waitbar_handle = [];
        start_time = NaN;
        last_time = NaN;
        last_msg = '';
    end
    methods
        function self = ProgressBar(N, msg)
            self.N = N; 
            if exist('msg','var')
                self.msg = msg;
            end
            self.waitbar_handle = waitbar(0,self.get_msg); 
            self.reset
        end
        function reset(self)
            self.index = 0;
            self.start_time = NaN;
            self.last_time = 0;
            self.elapsed_time = 0;
            if self.buffer_size > 0
                self.buffer = nan(self.buffer_size,1);
            end
            self.update;
        end
        function start(self)
            self.start_time = tic;
            self.index = 1;
            self.update;
        end
        function msg = get_msg(self)
            msg = sprintf('%s [%d/%d] %s/%s', self.msg, self.index,...
                self.N, self.time2clock(self.elapsed_time),...
                self.time2clock(self.time_remaining+self.elapsed_time));
        end
        function next(self)
            if self.index == 0
                self.start
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
        function close(self)
            if ishandle(self.waitbar_handle)
                close(self.waitbar_handle)
            end
            if self.as_text
                fprintf('\n')
            end
        end
        function update(self)
            if isnan(self.start_time)
                return
            end
            self.elapsed_time = toc(self.start_time);
            self.time_remaining = self.estimate_remaining_time;
            new_msg = self.get_msg;
            if self.as_waitbar
                if ~ishandle(self.waitbar_handle)
                    self.waitbar_handle = waitbar(self.index/self.N,new_msg);
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
    methods (Static)
        function clockstr = time2clock(time)
            if isnan(time)
                clockstr = '--:--';
            else
                clockstr = sprintf('%02.0f:%02.0f',round(time/60),round(mod(time,60)));
            end
        end
    end
    
end