/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package common;

/**
 *
 * @author segovia
 */
public class Parameters {
 
    /******************************/
    //Johansson variables - BEGIN
               
    // Cross-section of tank i 
    //TANKS DIMENSIONS = 10 * 16 * 22 CM
    public static final double A1 = 160;  // 10*16
    public static final double A2 = 160;
    public static final double A3 = 160;
    public static final double A4 = 160;
    
    public static final double tankHigh = 19; 
    
    // Cross-section of the outlet hole of tank i
    public static final double a1 = 0.12; // 0.2 cm radio
    public static final double a2 = 0.12; // 0.1 cm radio
    public static final double a3 = 0.12; // 0.2 cm radio
    public static final double a4 = 0.03; // 0.1 cm radio
    
    //Pumps voltage
    public static final double voltage = 12;
    
    // Water flow ---- flow_i = k_i*voltage_i   
    // Pumps flow  4 Litres/min == 66.6667 cm3/seg
    // Pump model: SODIAL(R) Ultra Quiet DC 12V 3M 240L/H Brushless Motor Submersible Aquarium Pro Water Pump 
    public static final double k1 = 66.6667/voltage;   
    public static final double k2 = 66.6667/voltage;
    
    // Relation voltage - water level
    public static final double kc = 1;    
    
    //Pumps correlation
    public static final double gamma1 = 0.5;
    public static final double gamma2 = 0.5;
    
    //Gravity
    public static final double g = 981;
   
    
    // Initial water level in tank i
    // No debería ser cero - poner un valor a mano y luego los rellenamos manual
    public static final double h1_0 = 2;
    public static final double h2_0 = 3;
    public static final double h3_0 = 5;
    public static final double h4_0 = 6;    

    public static final double T1 = (A1/a1)*Math.sqrt((2*h1_0)/g);
    public static final double T2 = (A2/a2)*Math.sqrt((2*h2_0)/g);
    public static final double T3 = (A3/a3)*Math.sqrt((2*h3_0)/g);
    public static final double T4 = (A4/a4)*Math.sqrt((2*h4_0)/g);
                
                    
    /************************************/
}
