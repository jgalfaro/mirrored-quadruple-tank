classdef PI_get_wrong_datas < Controller
	properties
		K % Proportional gains
		Ti % Integral times
	end
	
	methods
		function self = PI_get_wrong_datas(K, Ti)
			self.K = K;
			self.Ti = Ti;
			
			self.n_inputs = length(K);
			self.n_outputs = length(K);
			self.n_states = length(K);
		end
		
		function dxcdt = derivatives(self, t, ~, ~, y_22_unattacked, ~, r)
			dxcdt = self.Ti.^(-1).*(r(t,[1 2 3 4]) - y_22_unattacked(t,[1 3 1 3]) - y_22_unattacked(t,[2 4 2 4]) - y_22_unattacked(t,[7 5 7 5]) - y_22_unattacked(t,[8 6 8 6]) );
		end
		
		function u = outputs(self, t, xc, ~, y_22_unattacked, ~, r)
			u = self.K.*xc(t) + self.K.*(r(t,[1 2 3 4]) - y_22_unattacked(t,[1 3 1 3]) - y_22_unattacked(t,[2 4 2 4]) - y_22_unattacked(t,[7 5 7 5]) - y_22_unattacked(t,[8 6 8 6]) );
        end
        
	end
end