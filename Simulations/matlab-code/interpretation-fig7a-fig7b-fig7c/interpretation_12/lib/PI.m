classdef PI < Controller
	properties
		K % Proportional gains
		Ti % Integral times
	end
	
	methods
		function self = PI(K, Ti)
			self.K = K;
			self.Ti = Ti;
			self.n_inputs = length(K);
			self.n_outputs = length(K);
			self.n_states = length(K);
		end
		
		function dxcdt = derivatives(self, t, ~, ~, y, ~, r)
			dxcdt = self.Ti.^(-1).*(r(t,[1 2]) - y(t,[1 3]) - y(t,[2 4]) - y(t,[7 5]) - y(t,[8 6]) );
		end
		
		function u = outputs(self, t, xc, ~, y, ~, r)
			u = self.K.*xc(t) + self.K.*(r(t,[1 2]) - y(t,[1 3]) - y(t,[2 4]) - y(t,[7 5]) - y(t,[8 6]) );
		end
    end
end