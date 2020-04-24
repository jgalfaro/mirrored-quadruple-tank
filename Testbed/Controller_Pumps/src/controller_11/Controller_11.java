package controller_11;

import calculus.JKalman;
import calculus.Matrix;
import static calculus.Matrix.identity;
import common.GenericController;
import common.PairSensorValue;
import common.SensorConnectionManager;
import common.Parameters;


/**
 *
 * @author segovia
 */
public class Controller_11 extends GenericController{
          
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
      
    public final long sleepBetweenComands = 100;
    public final long waitRead = 1;
    public final long maxWaitRead = 10; 
                            
    //Johansson variables - END
    /******************************/
    
    protected boolean runThread;
    protected final double precision = 0.1;
    protected PairSensorValue[] SCCM_sensor_values_pairs;
           
    
    public Controller_11(){
        
        super.inicializeNetworkComponents();
        
	runThread=false;
	SCCM_sensor_values_pairs= new PairSensorValue[2];
        for(int i=0;i<SCCM_sensor_values_pairs.length;i++){
            SCCM_sensor_values_pairs[i]=new PairSensorValue();
            registerSCCM(i);
        }                
    }
    
        
    @Override
    public void startControlling() throws InterruptedException {
        if(runThread) 
            return ;
        
        System.out.println("Starting regulating the level");
	runThread=true;
                
        Thread t = new Thread(new Runnable() {
            public void run() {
                 try {
                    /*****************************/
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

                    /**************************/
                    /**** INICIALIZE - FIN ****/
                    /**************************/
                                        
                    boolean[] pumps = {true, true, true, true};     
                    // SEND COMMAND
                    activatePumps(pumps[0], pumps[1], pumps[2], pumps[3]);                    
                    Thread.sleep(sleepBetweenComands);
                    
                    long startTime;
                    long duration;
                    long endTime;
                    double measureS0;
                    double measureS1;
                    while (runThread) {
                        
                        System.out.println("runThread\n");
                        
                        startTime = System.currentTimeMillis();
                        
                        // READ NEW MEASURES      
                        // WaterLevel = tankHigh - distance to water
                        getReadings();
                        System.out.println("getReadings\n");
                        measureS0 = SCCM_sensor_values_pairs[0].getLatestSensorLevels();
                        System.out.println("measureS0"+measureS0+"\n");
                        y_read.set(0,0, measureS0);
                        //setLatestSensorLevel (measureS0, 0);
                        
                        measureS1 = SCCM_sensor_values_pairs[1].getLatestSensorLevels();
                        System.out.println("measureS1"+measureS1+"\n");
                        y_read.set(0,1, measureS1);
                        //setLatestSensorLevel (measureS1, 1);

                        // CALCULATE NEW COMMAND                             
                        JKalman jk = null;
                        try {
                            jk = new JKalman(4,2,2);
                        } catch (Exception e) {
                            System.err.println("Main Thread ERROR: control thread error - exception: " + e);
                            return;
                        }
                        
                        //1. Estimate next state and measures using the dynamic of the system
                            //System control model 
                            // x(t+1) = Ax(t) +B(u(t) + w(t))
                            // y(t) = Cx(t) + Du(t) + v(t)
                        //2. Estimate the error with the measured y (residue)                         
                        //3. Rectificate state with the error  (Kalman filter)
                        //4. Calculate command variation according to the error (LQR)                        
                                        
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
                        System.out.println("u00:"+u.get(0, 0)+"\n");
                        pumps[0] = u.get(0, 0) > (Parameters.voltage/2);
                        
                        System.out.println("u10:"+u.get(1, 0)+"\n");
                        pumps[1] = u.get(1, 0) > (Parameters.voltage/2);
                        
                        pumps[2] = u.get(1, 0) > (Parameters.voltage/2);
                        
                        pumps[3] = u.get(0, 0) > (Parameters.voltage/2);
                        activatePumps(pumps[0], pumps[1], pumps[2], pumps[3]);

                        // SLEEP                        
                        endTime = System.currentTimeMillis();
                        duration = (endTime - startTime);
                        Thread.sleep(sleepBetweenComands-duration);
                    }

                    //IF end of control, THEN stop the system                     
                     activatePumps(false, false, false, false);
                    
                } catch (InterruptedException e) {
                        System.err.println("Main Thread: Control thread error, exception: " + e);
                        //If there is an error shut down the pumps
                        activatePumps(false, false, false, false);
                }
            }

            private void getReadings() throws InterruptedException {
                long startReadTime;
                long now;
                startReadTime = System.currentTimeMillis();
                getFreshSensorInputs();      
                now = System.currentTimeMillis();
                //while ((now-startReadTime<maxWaitRead) && (!isDataReceived())){
                Thread.sleep(waitRead);
                //}
            }
        });

        t.start();
    }
    
    private boolean isDataReceived(){
        
        int max = SCCM_sensor_values_pairs.length;
        int iter = 0;
        boolean result = true;
        while ((iter < max)&&(result)){
            result = result &&  SCCM_sensor_values_pairs[iter].getHasBeenRead();
        }
        return result;
    } 
            
    @Override
    public void stopControlling() throws InterruptedException 
    {
	runThread=false;      
        System.out.println("Stopping regulating the level ");
    }
    
    public void getFreshSensorInputs()
    {
        for (PairSensorValue SCCM_sensor_values_pair : SCCM_sensor_values_pairs) {
            
            SCCM_sensor_values_pair.setHasBeenRead(false);
            try {
                SCCM_sensor_values_pair.getSccm().sendInterrogationCommand();
            } catch (Exception e){
                System.out.println("Error: Controller - getFreshSensorInputs");
            }
        }
    }
    
    @Override
    public void activatePumps(boolean pump1, boolean pump2, boolean pump3, boolean pump4){
        super.accm.activatePumps(pump1, pump2, pump3, pump4);
    }
       
    @Override
    public void setLatestSensorLevel(double new_level,int sensor_nb){
      
        new_level = Parameters.tankHigh - new_level;
        System.out.println("setLatestSensorLevel "+Double.toString(new_level)+" from "+Integer.toString(sensor_nb));
	SCCM_sensor_values_pairs[sensor_nb].setLatestSensorLevels(new_level);
        SCCM_sensor_values_pairs[sensor_nb].setHasBeenRead(true);
        sensorPanel[sensor_nb].updateSensorValue(new_level);
    }
    
    
    /********************************************************/
    /********************************************************/
    /********************************************************/
           
    public void setSlavesToSilence(boolean yes)
    {
        for (PairSensorValue SCCM_sensor_values_pair : SCCM_sensor_values_pairs) {
            SCCM_sensor_values_pair.getSccm().setSilence(yes);
        }
        accm.setSilence(yes);
    }
    
    
    
    @Override
    public void resetSCCMPair(int sensor_nb){
        System.out.println("resetSCCMPair "+Integer.toString(sensor_nb));
	SCCM_sensor_values_pairs[sensor_nb].reset();
    }
    
    public void registerSCCM(int assigned_id){
	if(assigned_id <0)
	    return;
        System.out.println("registerSCCM with id "+Integer.toString(assigned_id));
        
        SCCM_sensor_values_pairs[assigned_id].setSccm(sccm[assigned_id]);
        sccm[assigned_id].registerSensorDataCallback(this, assigned_id);
        
    }
    
    public void unregisterSCCM(SensorConnectionManager sccm)
    {
	if(sccm == null )
	    return;
        System.out.println("unregisterSCCM with id "+Integer.toString(sccm.getIdSensorDataCallback()));
	sccm.resetAndResignSensorDataCallback();
    }
    
    public void unregisterSCCM(int assigned_id)
    {
	if( assigned_id<0 )
	    return;
        System.out.println("unregisterSCCM with id "+Integer.toString(assigned_id));
	SCCM_sensor_values_pairs[assigned_id].getSccm().resetAndResignSensorDataCallback();
    }
    
    public void unregisterSCCMs()
    {
        for (PairSensorValue SCCM_sensor_values_pair : SCCM_sensor_values_pairs) {
            if (SCCM_sensor_values_pair == null) {
                continue;
            }
            if (SCCM_sensor_values_pair.getSccm() == null) {
                continue;
            }
            System.out.println("unregisterSCCM with id " + Integer.toString(SCCM_sensor_values_pair.getSccm().getIdSensorDataCallback()));
            SCCM_sensor_values_pair.getSccm().resetAndResignSensorDataCallback();
        }
    }  
    
    public float convertSensorInputToDecisionLevel()
    {
	float r=0;
        int s=0;
        for (PairSensorValue SCCM_sensor_values_pair : SCCM_sensor_values_pairs) {
            double v = SCCM_sensor_values_pair.getLatestSensorLevels();
            if(v >0)
            {
                r+=v;
                s++;
            }
        }
        if(s<=0)
            s=1;
	/*TODO: refine le logic instead of simple mean value*/
        r=r/s;
        return r;
    }
}
