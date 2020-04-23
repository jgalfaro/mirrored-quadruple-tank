classdef QuadrupleTank < Process
	properties
		a % Cross-sections of the outlets holes
		A % Cross-sections of the tanks
		g % Acceleration of gravity
		gamma % Positions of the valves
		k % Voltage to volumetric flow rate gains
	end
	
	methods
		function self = QuadrupleTank(a, A, g, gamma, k)
			if ndims(a) ~= 2 || length(a) ~= 4
				error('Cross-sections of the outlets holes must be a vector of length 4.');
			end
			if ndims(A) ~= 2 || length(A) ~= 4
				error('Cross-sections of the tanks must be a vector of length 4.');
			end
			if ~isscalar(g)
				error('Acceleration of gravity must be a scalar.');
			end
			if ndims(gamma) ~= 2 || length(gamma) ~= 2
				error('Positions of the valves must be a vector of length 2.');
			end
			if ndims(k) ~= 2 || length(k) ~= 2
				error('Voltage to volumetric flow rate gains must be a vector of length 2.');
			end
			
			self.a = a;
			self.A = A;
			self.g = g;
			self.gamma = gamma;
			self.k = k;
			
			self.n_inputs = 2;
			self.n_outputs = 2;
			self.n_states = 4;
		end
		
		function dxdt = derivatives(self, t, x, u, ~, ~)
			dxdt = zeros(4, 1);
			
			xt = x(t);
			
			dxdt(1) = -self.a(1)/self.A(1)*sqrt(2*self.g*xt(1)) + self.a(3)/self.A(1)*sqrt(2*self.g*xt(3)) + self.gamma(1)*self.k(1)/self.A(1)*u(t,1);
            dxdt(2) = -self.a(2)/self.A(2)*sqrt(2*self.g*xt(2)) + self.a(4)/self.A(2)*sqrt(2*self.g*xt(4)) + self.gamma(2)*self.k(2)/self.A(2)*u(t,2);
            dxdt(3) = -self.a(3)/self.A(3)*sqrt(2*self.g*xt(3)) + (1-self.gamma(2))*self.k(2)/self.A(3)*u(t,2);
            dxdt(4) = -self.a(4)/self.A(4)*sqrt(2*self.g*xt(4)) + (1-self.gamma(1))*self.k(1)/self.A(4)*u(t,1);
		end
		
		function y = outputs(self, t, x, u, ~, ~)
			y = x(t, [1 2]);
		end
	end
end
