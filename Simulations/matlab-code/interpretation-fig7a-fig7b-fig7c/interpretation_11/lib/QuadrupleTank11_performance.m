classdef QuadrupleTank11_performance < Process
	properties
		a % Cross-sections of the outlets holes
		A % Cross-sections of the tanks
		g % Acceleration of gravity
		gamma % Positions of the valves
		k % Voltage to volumetric flow rate gains
	end
	
	methods
		function self = QuadrupleTank11_performance(a, A, g, gamma, k)
			self.a = a;
			self.A = A;
			self.g = g;
			self.gamma = gamma;
			self.k = k;
			self.n_inputs = 2;
			self.n_outputs = 4;
			self.n_states = 5;
		end
		
		function dxdt = derivatives(self, t, x, u, ~, ~)
			dxdt = zeros(5, 1);
			
			xt = x(t);
            
            
                
                dxdt(1) = -self.a(1)/self.A(1)*sqrt(2*self.g*xt(1)) + self.a(3)/self.A(1)*sqrt(2*self.g*xt(3)) + self.gamma(1)*self.k(1)/self.A(1)*u(t,1);
                dxdt(2) = -self.a(2)/self.A(2)*sqrt(2*self.g*xt(2)) + self.a(4)/self.A(2)*sqrt(2*self.g*xt(4)) + self.gamma(2)*self.k(2)/self.A(2)*u(t,2);
                dxdt(3) = -self.a(3)/self.A(3)*sqrt(2*self.g*xt(3)) + (1-self.gamma(2))*self.k(2)/self.A(3)*u(t,2);
                dxdt(4) = -self.a(4)/self.A(4)*sqrt(2*self.g*xt(4)) + (1-self.gamma(1))*self.k(1)/self.A(4)*u(t,1); 
                dxdt(5) = self.a(1)/self.A(5)*sqrt(2*self.g*xt(1)) + self.a(2)/self.A(5)*sqrt(2*self.g*xt(2)) - self.k(1)/self.A(5)*u(t,1) - self.k(2)/self.A(5)*u(t,2);
           
               
                if t > 508
                    self.gamma(1) = 0.95;
                
                    dxdt(1) = -self.a(1)/self.A(1)*sqrt(2*self.g*xt(1)) + self.a(3)/self.A(1)*sqrt(2*self.g*xt(3)) + self.gamma(1)*self.k(1)/self.A(1)*(u(t,1)+u(t,1)*0.5);
                    dxdt(2) = -self.a(2)/self.A(2)*sqrt(2*self.g*xt(2)) + self.a(4)/self.A(2)*sqrt(2*self.g*xt(4)) + self.gamma(2)*self.k(2)/self.A(2)*u(t,2);
                    dxdt(3) = -self.a(3)/self.A(3)*sqrt(2*self.g*xt(3)) + (1-self.gamma(2))*self.k(2)/self.A(3)*u(t,2);
                    dxdt(4) = -self.a(4)/self.A(4)*sqrt(2*self.g*xt(4)) + (1-self.gamma(1))*self.k(1)/self.A(4)*(u(t,1)+u(t,1)*0.5); 
                    dxdt(5) = self.a(1)/self.A(5)*sqrt(2*self.g*xt(1)) + self.a(2)/self.A(5)*sqrt(2*self.g*xt(2)) - self.k(1)/self.A(5)*(u(t,1)+u(t,1)*0.5) - self.k(2)/self.A(5)*u(t,2);
            
                end
            
            
			
        end
		
		function y = outputs(self, t, x, u, ~, ~)
            y = zeros(4,1);
 			y(1) = x(t, 1);
            y(2) = x(t, 2);
            y(3) = x(t, 3);
            y(4) = x(t, 4);
		end
	end
end