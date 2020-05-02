classdef QuadrupleTank22 < Process
	properties
		a % Cross-sections of the outlets holes
		A % Cross-sections of the tanks
		g % Acceleration of gravity
		gamma % Positions of the valves
		k % Voltage to volumetric flow rate gains
        n % fraction of liquid
        lambda % pump coef cm^3 / V second
        w % voltage not controllable from the cyber-space
	end
	
	methods
		function self = QuadrupleTank22(a, A, g, gamma, k, n, lambda, w)
			self.a = a;
			self.A = A;
			self.g = g;
			self.gamma = gamma;
			self.k = k;
            self.n = n;
            self.lambda = lambda;
            self.w = w;
			self.n_inputs = 4;
			self.n_outputs = 8;
			self.n_states = 5;
		end
		
		function dxdt = derivatives(self, t, x, u, ~, ~)
			dxdt = zeros(5, 1);
			xt = x(t);
			dxdt(1) = -self.a(1)/self.A(1)*sqrt(2*self.g*xt(1)) + self.a(3)/self.A(1)*sqrt(2*self.g*xt(3)) + self.gamma(1)*self.k(1)/self.A(1)*u(t,1) + self.n(1)*self.lambda(1)*self.w(1)/self.A(1)*u(t,3);
            dxdt(2) = -self.a(2)/self.A(2)*sqrt(2*self.g*xt(2)) + self.a(4)/self.A(2)*sqrt(2*self.g*xt(4)) + self.gamma(2)*self.k(2)/self.A(2)*u(t,2) + self.n(2)*self.lambda(2)*self.w(2)/self.A(2)*u(t,4);
            dxdt(3) = -self.a(3)/self.A(3)*sqrt(2*self.g*xt(3)) + (1-self.gamma(2))*self.k(2)/self.A(3)*u(t,2) + (1-self.n(2))*self.lambda(2)*self.w(2)/self.A(3)*u(t,4);
            dxdt(4) = -self.a(4)/self.A(4)*sqrt(2*self.g*xt(4)) + (1-self.gamma(1))*self.k(1)/self.A(4)*u(t,1) + (1-self.n(1))*self.lambda(1)*self.w(1)/self.A(4)*u(t,3);
            dxdt(5) = self.a(1)/self.A(5)*sqrt(2*self.g*xt(1)) + self.a(2)/self.A(5)*sqrt(2*self.g*xt(2)) - self.k(1)/self.A(5)*u(t,1) - self.k(2)/self.A(5)*u(t,2); 
        end
		
		function y = outputs(self, t, x, u, ~, ~)
            y = zeros(8,1);
  			y(1) = x(t, 1);
            y(2) = self.gamma(1)*self.k(1) + self.n(1)*self.lambda(1)*self.w(1); % 1 3
            y(3) = x(t, 2);
            y(4) = self.gamma(2)*self.k(2) + self.n(2)*self.lambda(2)*self.w(2); % 2 4
            y(5) = x(t, 3);
            y(6) = (1-self.gamma(2))*self.k(2) + (1-self.n(2))*self.lambda(2)*self.w(2); % 2 4
            y(7) = x(t, 4);
            y(8) = (1-self.gamma(1))*self.k(1) + (1-self.n(1))*self.lambda(2)*self.w(1); % 1 3
        end
	end
end