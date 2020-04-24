classdef PI < PCS.Control.Controller
	properties
		K % Proportional gains
		Ti % Integral times
	end
	
	methods
		function self = PI(K, Ti)
% 			if ndims(K) > 2
% 				error('Proportional gains must be a vector.');
% 			end
% 			if ndims(Ti) > 2
% 				error('Integral times must be a vector.');
% 			end
% 			if length(K) ~= length(Ti)
% 				error('The lengths of the proportional gains and integral times must match.');
% 			end
			
			self.K = K;
			self.Ti = Ti;
			
			self.n_inputs = length(K);
			self.n_outputs = length(K);
			self.n_states = length(K);
		end
		
		function dxcdt = derivatives(self, t, ~, ~, y, ~, r)
			dxcdt = self.Ti.^(-1).*(r(t,[1 2 3 4]) - y(t,[1 3 1 3]) - y(t,[2 4 2 4]) - y(t,[7 5 7 5]) - y(t,[8 6 8 6]) );
		end
		
		function u = outputs(self, t, xc, ~, y, ~, r)
			u = self.K.*xc(t) + self.K.*(r(t,[1 2 3 4]) - y(t,[1 3 1 3]) - y(t,[2 4 2 4]) - y(t,[7 5 7 5]) - y(t,[8 6 8 6]) );
            %u(1) = u(1)*2;
        end
        
	end
end