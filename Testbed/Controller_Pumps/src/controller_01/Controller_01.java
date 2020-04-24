
package controller_01;


import common.GenericController;
import common.PairSensorValue;
import common.Parameters;
import common.SensorConnectionManager;



/**
 *
 * @author Will
 */
public class Controller_01 extends GenericController{
    
    protected boolean is_running;
    protected float desired_level;
    protected float precision;
    private Thread saac_thread;
    private final RunnableCtl_01 rsaac;
    protected PairSensorValue[] SCCM_sensor_values_pairs;
           
    
    public Controller_01(){
	
        super.inicializeNetworkComponents();
        
	is_running=false;
	SCCM_sensor_values_pairs= new PairSensorValue[2];
        for(int i=0;i<SCCM_sensor_values_pairs.length;i++){
            SCCM_sensor_values_pairs[i]=new PairSensorValue();
            registerSCCM(i);
        }
        precision=0;
        desired_level=18;
        rsaac=new RunnableCtl_01();
        rsaac.setCtl(this);
        saac_thread= null;//new Thread(rsaac); will be set in the startRegulating() function
        
    }
      
    public String getDesiredLevelString()
    {
        return (Float.toString(desired_level)+" +/- "+Float.toString(precision));
    }
    
    public void printWithName(String msg)
    {
        System.out.println("(SensorToActuatorAutomaticController:) "+msg);
    }
        
    public void setSlavesToSilence(boolean yes)
    {
        for (PairSensorValue SCCM_sensor_values_pair : SCCM_sensor_values_pairs) {
            SCCM_sensor_values_pair.getSccm().setSilence(yes);
        }
        accm.setSilence(yes);
    }
    
    @Override
    public void setLatestSensorLevel(double new_level,int sensor_nb){
        
        new_level = Parameters.tankHigh - new_level;        
        if(is_running && false)
            printWithName("setLatestSensorLevel "+Double.toString(new_level)+" from "+Float.toString(sensor_nb));
	SCCM_sensor_values_pairs[sensor_nb].setLatestSensorLevels(new_level);
        sensorPanel[sensor_nb].updateSensorValue(new_level);
    }
    
    @Override
    public void resetSCCMPair(int sensor_nb){
        printWithName("resetSCCMPair "+Integer.toString(sensor_nb));
	SCCM_sensor_values_pairs[sensor_nb].reset();
    }
    
    public void registerSCCM(int assigned_id){
	if(assigned_id <0)
	    return;
        printWithName("registerSCCM with id "+Integer.toString(assigned_id));
        
        SCCM_sensor_values_pairs[assigned_id].setSccm(sccm[assigned_id]);
        sccm[assigned_id].registerSensorDataCallback(this, assigned_id);
        
    }
    
    public void unregisterSCCM(SensorConnectionManager sccm)
    {
	if(sccm == null )
	    return;
        printWithName("unregisterSCCM with id "+Integer.toString(sccm.getIdSensorDataCallback()));
	sccm.resetAndResignSensorDataCallback();
    }
    
    public void unregisterSCCM(int assigned_id)
    {
	if( assigned_id<0 )
	    return;
        printWithName("unregisterSCCM with id "+Integer.toString(assigned_id));
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
            printWithName("unregisterSCCM with id " + Integer.toString(SCCM_sensor_values_pair.getSccm().getIdSensorDataCallback()));
            SCCM_sensor_values_pair.getSccm().resetAndResignSensorDataCallback();
        }
    }

    public void setDesiredLevel(float desired_level) {
        this.desired_level = desired_level;
    }
    
    public void setDesiredLevel(int desired_level_in_mm) {
        this.desired_level = (desired_level_in_mm/10.0F);
        
    }

    public void setPrecision(float precision) {
        this.precision = precision;        
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
    
    /**
     * TODO:
     * THIS FUNCTION IS TO BE REMOVED IT SHOULD NOT BE NECESSARY ONCE THE SENSORS 
     * AUTOMATICALLY SEND THEIR DATA PERIODICALLY
     */
    public void getFreshSensorInputs()
    {
        for (PairSensorValue SCCM_sensor_values_pair : SCCM_sensor_values_pairs) {
            try {
                SCCM_sensor_values_pair.getSccm().sendInterrogationCommand();
            }catch (Exception e){}
        }
    }
    
    @Override
    public void stopControlling() throws InterruptedException 
    {
	is_running=false;
        saac_thread.join();
        printWithName("Stopping regulating the level ");
    }
    
    /**
     * @throws java.lang.InterruptedException
     */
    @Override
    public void startControlling() throws InterruptedException
    {
         if(is_running && saac_thread!=null)
        {
            System.err.println("Stopping and restarting the saac thread to chang the desired level and precision");
            stopControlling();
        }
        saac_thread= new Thread(rsaac);
        printWithName("Starting regulating the level to "+Float.toString(desired_level)+" +/- "+Float.toString(precision));
	is_running=true;
        saac_thread.start();
    }

    @Override
    public void activatePumps(boolean pump1, boolean pump2, boolean pump3, boolean pump4){
        super.accm.activatePumps(pump1, pump2, pump3, pump4);
    }

}