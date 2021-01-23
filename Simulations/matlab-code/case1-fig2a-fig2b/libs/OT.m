classdef OT < Process
	properties
		a % Cross-sections of the outlets holes
		A % Cross-sections of the tanks
		g % Acceleration of gravity
		gamma % Positions of the valves
		k % Voltage to volumetric flow rate gains
	end
	
	methods
		function self = OT(a, A, g, gamma, k)
			self.a = a;
			self.A = A;
			self.g = g;
			self.gamma = gamma;
			self.k = k;
			self.n_inputs = 1;
			self.n_outputs = 3;
			self.n_states = 1;
		end
		
		function dxdt = derivatives(self, t, x, u, ~, ~)
			dxdt = zeros(1, 1);
			xt = x(t);
            dxdt(1) = -self.a(1)/self.A(1)*sqrt(2*self.g*xt(1)) + (1-self.gamma(1))*self.k(1)/self.A(1)*(u(t,1));
        end
		
		function y = outputs(self, t, x, u, ~, ~)
            y = zeros(3,1);
			y(1) = x(t, 1);
            y(2) = self.gamma(1)*self.k(1)/self.A(1);
            y(3) = x(t, 1)*self.a(1)/self.A(1)*sqrt(2*self.g*x(t,1));
		end
	end
end