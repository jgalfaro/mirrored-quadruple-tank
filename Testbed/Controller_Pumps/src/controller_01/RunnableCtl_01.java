
package controller_01;

import pumps_control.TernaryPump;

/**
 *
 * @author segovia
 */    
public class RunnableCtl_01 implements Runnable
{
    protected Controller_01 ctl;
    int timeout_ms;
    int ticks_bf_action;

    TernaryPump.TERNARY_PUMP_STATE wished_decision;
    TernaryPump.TERNARY_PUMP_STATE latest_decision;
    int ticks_since_last_decision;

    public RunnableCtl_01()
    {
        ctl=null;
        timeout_ms=100;
        ticks_bf_action=500/timeout_ms;
        resetwishedDirection();
    }

    protected void resetwishedDirection()
    {
        ticks_since_last_decision=0;
        latest_decision=TernaryPump.TERNARY_PUMP_STATE.OFF;
        wished_decision=TernaryPump.TERNARY_PUMP_STATE.OFF;         
    }

    @Override
    public void run()
    {
        resetwishedDirection();
        ctl.setSlavesToSilence(true);
        ctl.getFreshSensorInputs();
        float min_accepted=ctl.desired_level-ctl.precision;
        float max_accepted=ctl.desired_level+ctl.precision;
        while(ctl.is_running)
        {	    
            float decision_lvl=ctl.convertSensorInputToDecisionLevel();

            //we do it now for the next iteration because the request-answer is slow
            ctl.getFreshSensorInputs();
            if(decision_lvl<min_accepted)
                wished_decision=TernaryPump.TERNARY_PUMP_STATE.BACKWARDS;
            else if (decision_lvl> max_accepted)
                wished_decision=TernaryPump.TERNARY_PUMP_STATE.FORWARD;
            else
                wished_decision=TernaryPump.TERNARY_PUMP_STATE.OFF;
            mayActIfChangeNeeded();
            try {
                Thread.sleep(timeout_ms);
            } catch (InterruptedException ex) {
                ctl.printWithName("Automatic thread interrupted");
                break;
            }
        }
        ctl.activatePumps(false, false, false, false);
        ctl.is_running=false;
        ctl.setSlavesToSilence(false);
    }

    protected void mayActIfChangeNeeded()
    {
        ticks_since_last_decision++;
        if(ticks_since_last_decision >ticks_bf_action )
        {
            actOnDecision();
        }
        else if(wished_decision != latest_decision)
        {
            actOnDecision();    
        }
        return;            
    }

    protected void actOnDecision()
    {
        switch(wished_decision)
        {
            case OFF:
                ctl.activatePumps(false, false, false, false);
                break;
            case FORWARD:
                ctl.activatePumps(true, true, true, true);
                break;
            /*case BACKWARDS:
                ctl.accm.sendBackwardsAll();
                break;    */                
        }
        latest_decision=wished_decision;
        ticks_since_last_decision=0;
    }

    protected void setCtl(Controller_01 ssac)
    {
        if(ctl==null)
            ctl=ssac;
    }

    public int getTimeout_ms() {
        return timeout_ms;
    }

    public void setTimeout_ms(int timeout_ms) {
        this.timeout_ms = timeout_ms;
    }

    public int getTicks_bf_action() {
        return ticks_bf_action;
    }

    public void setTicks_bf_action(int ticks_bf_action) {
        this.ticks_bf_action = ticks_bf_action;
    }

    public int getTicks_since_last_decision() {
        return ticks_since_last_decision;
    }

    public void setTicks_since_last_decision(int ticks_since_last_decision) {
        this.ticks_since_last_decision = ticks_since_last_decision;
    }

}
    
