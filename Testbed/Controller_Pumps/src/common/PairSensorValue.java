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
public class PairSensorValue {
    final protected static float DEFAULT_VALUE_SENSOR=-1;
    protected SensorConnectionManager sccm;
    protected double latest_sensor_levels;
    protected boolean hasBeenRead;

    public PairSensorValue()
    {
        sccm=null;
        latest_sensor_levels=DEFAULT_VALUE_SENSOR;
        hasBeenRead = false;
    }

    public SensorConnectionManager getSccm() {
        return sccm;
    }

    public void setSccm(SensorConnectionManager sccm) {
        this.sccm = sccm;
    }
    
    public boolean getHasBeenRead(){
        return hasBeenRead;
    }
    
    public void setHasBeenRead(boolean hbr){
        this.hasBeenRead = hbr;
    }

    public double getLatestSensorLevels() {
        return latest_sensor_levels;
    }

    public void setLatestSensorLevels(double latest_sensor_levels) {
        this.latest_sensor_levels = latest_sensor_levels;
    }

    public void reset() {
        sccm=null;
        latest_sensor_levels=DEFAULT_VALUE_SENSOR;
    }        

}
