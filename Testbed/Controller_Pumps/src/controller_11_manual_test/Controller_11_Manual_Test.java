package controller_11_manual_test;

import calculus.JKalman;
import calculus.Matrix;
import static calculus.Matrix.identity;
import common.Parameters;


/**
 *
 * @author segovia
 */
public class Controller_11_Manual_Test{
          
    private double[][] A;
    Matrix mxA;
    private double[][] B;
    Matrix mxB;
    private double[][] C;
    Matrix mxC;
    
    /** predicted state (x'(k)): x(k)=A*x(k-1)+B*u(k) */    
    Matrix x_pre = new Matrix (4,1,0.0);    // STATE PREDICTED
    /** corrected state (x(k)): x(k)=x'(k)+K(k)*(z(k)-H*x'(k)) */    
    Matrix x_post = new Matrix (4,1,0.0);   // STATES CORRECTED     
    
    Matrix u = new Matrix (2,1,Parameters.voltage);           // COMMANDS          
    Matrix y_read = new Matrix (1,2,0.0);                    // MEASURES       
             
    JKalman jk = null;
    
    // kalman filter
    Matrix kf = new Matrix (1,2);    
    	
    //P --> Covariance of error
    Matrix P = new Matrix(4,4,0.0);			
    //Residue=distance -Cx
    Matrix residue = new Matrix(1,1,0.0);			
    // sensor noise R
    double [][] R_m= {{0.8, 0.0}, 
                    {0.0, 0.8}};  
    Matrix R = new Matrix(R_m);
    //Process noise
    double [][] Q_m={{1, 0.0, 0.0, 0.0}, 
                    {0.0, 1, 0.0, 0.0}, 
                    {0.0, 0.0, 1, 0.0}, 
                    {0.0, 0.0, 0.0, 1}}; 
    Matrix Q = new Matrix(Q_m);

     // LQG controller
    Matrix feedback_gain;
    Matrix ponderation1=identity (2,2);//new Matrix(2,2,1.0);// U 37.7
    Matrix ponderation2=identity (4,4); //new Matrix(4,4,1.0);// W
      
                            
    //Johansson variables - END
    /******************************/
    
    protected final double precision = 0.1;
    
    public Controller_11_Manual_Test(){
        
        /****************************/
        /**** INICIALIZE - BEGIN ****/
        /****************************/

        A = new double[][] {{-1/Parameters.T1, 0, Parameters.A3/(Parameters.A1*Parameters.T3), 0},
                            {0, -1/Parameters.T2, 0, Parameters.A4/(Parameters.A2*Parameters.T4)},
                            {0, 0, -1/Parameters.T3, 0},
                            {0, 0, 0, -1/Parameters.A4}};
        mxA = new Matrix(A);

        B = new double[][] {{(Parameters.gamma1*Parameters.k1)/Parameters.A1, 0},
                            {0, (Parameters.gamma2*Parameters.k2)/Parameters.A2},
                            {0, ((1-Parameters.gamma2)*Parameters.k2)/Parameters.A3},
                            {((1-Parameters.gamma1)*Parameters.k1)/Parameters.A4, 0}};
        mxB = new Matrix(B);

        C = new double[][] {{Parameters.kc, 0, 0, 0},                                                  
                            {0, Parameters.kc, 0, 0}};
        mxC = new Matrix(C);
        
         // CALCULATE NEW COMMAND                             
       
        try {
            jk = new JKalman(4,2,2);
        } catch (Exception e) {
            System.err.println("Main Thread ERROR: control thread error - exception: " + e);
            return;
        }
     
        jk.setTransition_matrix(mxA);
        jk.setControl_matrix(mxB);
        jk.setMeasurement_matrix(mxC);  

        //inicialize
        jk.setState_pre(x_post);
        jk.setState_post(x_post);

        //Noise
        jk.setMeasurement_noise_cov(R);
        jk.setProcess_noise_cov(Q);
        jk.setError_cov_post(P);
    }
    
       
    public void controlling(double measureS0, double measureS1) throws InterruptedException {
        
        System.out.println("Starting regulating the level");
                
                 
        /**************************/
        /**** INICIALIZE - FIN ****/
        /**************************/

        boolean[] pumps = {true, true, true, true};     

        y_read.set(0,0, measureS0);
        y_read.set(0,1, measureS1);
       

        //1. Estimate next state and measures using the dynamic of the system
            //System control model 
            // x(t+1) = Ax(t) +B(u(t) + w(t))
            // y(t) = Cx(t) + Du(t) + v(t)
        //2. Estimate the error with the measured y (residue)                         
        //3. Rectificate state with the error  (Kalman filter)
        //4. Calculate command variation according to the error (LQR)                        


        // (x'(k)): x(k)=A*x(k-1)+B*u(k)
        // state estimation (x_pre) without kalman correction                        
        x_pre=jk.Predict(u, true);
        jk.setState_pre(x_pre);                                                                          

        // x(k)=x'(k)+K(k)*(y -C*x'(k))
        //residue= real_measure- estimated_measure
       jk.setResidue(residue);
       x_post=jk.Correct_d(y_read);	
       residue.set(0, 0, jk.getResidue().get(0,0));  	

        jk.setState_post(x_post);


        // new control action for the next status
        // u_post = u_pre + L*x 
        feedback_gain=jk.Local_LQG_control(ponderation1,ponderation2);      //L                  
        Matrix feedback=jk.Remote_Control_Action(feedback_gain);
        u=feedback.plus(u);  


        // SEND COMMAND TO DE PUMPS
        
        pumps[0] = u.get(0, 0) > (Parameters.voltage/2);
        System.out.println("u00:"+u.get(0, 0)+"\n");
        System.out.println("p0:"+pumps[0]+"\n");
        
        
        pumps[1] = u.get(1, 0) > (Parameters.voltage/2);
        System.out.println("u10:"+u.get(1, 0)+"\n");        
        System.out.println("p1:"+pumps[1]+"\n");

        pumps[2] = u.get(1, 0) > (Parameters.voltage/2);        
        System.out.println("p2:"+pumps[2]+"\n");

        pumps[3] = u.get(0, 0) > (Parameters.voltage/2); 
        System.out.println("p3:"+pumps[3]+"\n");                     

    }
    
}
