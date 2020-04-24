classdef (Abstract) Controller_attacked < PCS.System
    %Controller  of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods (Abstract)
        dxcdt = derivatives_attacked(self,t,xc,x,y,d,r);
        
        u = outputs_attacked(self,t,xc,x,y,d,r);
        
    end 
end