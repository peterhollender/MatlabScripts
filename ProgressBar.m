classdef ProgressBar < handle
    properties
        percent_done = 0;
        N = 1;
        index = 0;
        time_remaining = NaN;
        elapsed_time = 0;
        msg = '';
    end
    properties (Hidden=true)
        buffer = [0];
        min_buffer = 1;
        buffer_size = 1;
        waitbar_handle = [];
        start_time = NaN;
        last_time = NaN;
    end
    methods
        function self = ProgressBar(N, msg)
            self.N = N; 
            if exist('msg','var')
                self.msg = msg;
            end
            self.index = 0;
            self.start_time = tic;
            self.buffer_size = N;
            self.buffer = nan(self.buffer_size,1);
            self.waitbar_handle = waitbar(0,self.get_msg); 
        end
        function reset(self)
            self.index = 0;
            self.start_time = tic;
            self.last_time = 0;
            self.buffer = nan(self.buffer_size,1);
            self.update;
        end
        function msg = get_msg(self)
            msg = sprintf('%s [%d/%d] %s/%s', self.msg, self.index,...
                self.N, self.time2clock(self.elapsed_time),...
                self.time2clock(self.time_remaining+self.elapsed_time));
        end
        function increment(self)
            self.index = self.index+1;
            new_time = toc(self.start_time);
            self.buffer(mod(self.index - 1,self.buffer_size)+1) = new_time-self.last_time;
            self.last_time = new_time;
            if self.index > self.N
                close(self.waitbar_handle)
            else
                self.update;
            end
        end
        function t_avg = time_per_inc(self)
            if self.index < self.min_buffer
                t_avg = NaN;
            else
                t_avg = nanmean(self.buffer);
            end
        end
        function t_remain = estimate_remaining_time(self)
            t_avg = self.time_per_inc;
            t_remain = (self.N-self.index)*t_avg;
        end
        function update(self)
            if isnan(self.start_time)
                return
            end
            self.elapsed_time = toc(self.start_time);
            self.time_remaining = self.estimate_remaining_time;
            if ~ishandle(self.waitbar_handle)
                self.waitbar_handle = waitbar(self.index/self.N,self.get_msg);
            else
                waitbar(self.index/self.N,self.waitbar_handle,self.get_msg);
            end
        end
    end
    methods (Static)
        function clockstr = time2clock(time)
            if isnan(time)
                clockstr = '--:--';
            else
                clockstr = sprintf('%02d:%02d',floor(time/60),floor(mod(time,60)));
            end
        end
    end
    
end