package common;


import graphics.SensorPanel;
import org.openmuc.j60870.Connection;

/**
 *
 * @author segovia
 */
public abstract class GenericController implements ControllerInterface{
    
    protected SensorConnectionManager[] sccm = new SensorConnectionManager[2];    
    protected SensorPanel[] sensorPanel = new SensorPanel[2];    
    protected Connection[] connection_sensor = new Connection[2];
    
    protected ActuatorConnectionManager accm;
    protected Connection connection_actuator;
            
    @Override
    public void inicializeNetworkComponents(){
      
           
        //SENSOR1	
	//Starting connection
	sccm[0]=new SensorConnectionManager("192.168.10.11", 2404, 1, "SCCM 1");	
	boolean connection_with_sensor1= sccm[0].startConnection();
	       
        if(!connection_with_sensor1){
	    //TODO 
            //Log - message to user          	    
	}
		
        //SENSOR 2
        //IP Address initialization
        sccm[1]=new SensorConnectionManager("192.168.110.11", 2404, 1, "SCCM 2");	
	boolean connection_with_sensor2= sccm[1].startConnection();
        			
        if(!connection_with_sensor2){
	    //TODO 
            //Log - message to user          	    
	}
	
	
        //ACTUATOR
    	//IP Address initialization
        accm=new ActuatorConnectionManager("192.168.20.11", 2404, 1, "ACCM");        
	boolean connection_with_actuator= accm.startConnection();
        			
        if(!connection_with_actuator){
	    //TODO 
            //Log - message to user          	    
	}		
    }
    
    @Override
    public void subscribeSensorListener(int sensorId, SensorPanel sp){
        sensorPanel[sensorId] = sp;
    }
    
    @Override
    public void sendLedOn (int sensorId){        
        sccm[sensorId].sendLedOn();        
    }
    
    @Override
    public void sendLedOff (int sensorId){
        sccm[sensorId].sendLedOff();        
    }
    
    @Override
    public void activatePumps(boolean pump1, boolean pump2, boolean pump3, boolean pump4){
        accm.activatePumps(pump1, pump2, pump3, pump4);
    }
    
    
    
    @Override
    public void sendInterrogationCommand(int sensorId){
        if (sensorId >= 0){
            sccm[sensorId].sendInterrogationCommand();
        }                
        else {
            accm.sendInterrogationCommand();
        }
    }

    @Override
    public void sendSynchronizeClock(int sensorId){
        if (sensorId >= 0){
            sccm[sensorId].sendSynchronizeClock();
        }        
        else {
            accm.sendSynchronizeClock();
        }
    }

    @Override
    public void sendCloseConnection(int sensorId){
        if (sensorId >= 0){
            sccm[sensorId].sendCloseConnection();
        }        
        else {
            accm.sendCloseConnection();
        }
    }

    @Override
    public void sendStopServer(int sensorId){
        if (sensorId >= 0){
            sccm[sensorId].sendStopServer();
        }
        else {
            accm.sendStopServer();
        }
    }
   
}
