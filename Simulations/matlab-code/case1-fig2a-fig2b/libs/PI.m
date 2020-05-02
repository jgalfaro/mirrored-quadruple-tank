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
			dxcdt = self.Ti.^(-1).*(r(t,1) - y(t,1) - y(t,2) - y(t,3));
		end
		
		function u = outputs(self, t, xc, ~, y, ~, r)
			u = self.K.*xc(t) + self.K.*(r(t,1) - y(t,1) - y(t,2) - y(t,3));
		end
	end
end