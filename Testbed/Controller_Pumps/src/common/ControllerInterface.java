package common;

import graphics.SensorPanel;



/**
 *
 * @author will
 */
public interface ControllerInterface {
        
    public abstract void inicializeNetworkComponents();

    public void sendInterrogationCommand(int sensorId);

    public void sendSynchronizeClock(int sensorId);

    public void sendCloseConnection(int sensorId);

    public void sendStopServer(int sensorId);
    
    public abstract void resetSCCMPair(int sensor_nb);
    
    public abstract void setLatestSensorLevel(double new_level,int sensor_nb);
    
    public void startControlling() throws InterruptedException;

    public void stopControlling() throws InterruptedException;
    
    public void sendLedOn (int sensorId);
    
    public void sendLedOff (int sensorId);     
    
    public void activatePumps(boolean pump1, boolean pump2, boolean pump3, boolean pump4);
    
    public void subscribeSensorListener(int sensorId, SensorPanel sensorPanel);
}
