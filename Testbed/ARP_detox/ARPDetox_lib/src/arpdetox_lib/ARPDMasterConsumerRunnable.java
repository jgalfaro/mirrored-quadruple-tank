/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package arpdetox_lib;

import static arpdetox_lib.ARPDMessage.*;
import static arpdetox_lib.ARPDMessage.ARPD_MESSAGE_TYPE.*;
import arpdetox_lib.ARPDServer.*;
import static arpdetox_lib.ARPDServer.ARDP_SLAVE_PORT;
import static arpdetox_lib.ARPDServer.mess_logger;
import arpdetox_lib.ARPDSession.*;
import static arpdetox_lib.ARPDSession.ARPDSessionState.*;
import arpdetox_lib.ARPDSessionContainer.*;
import arpdetox_lib.IPInfoContainers.DestIPInfo;
import java.net.Inet4Address;
import java.net.UnknownHostException;
import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author will
 */
public class ARPDMasterConsumerRunnable extends ConsumerRunnable<ARPDServerMaster>
{
    public boolean handleAnswer(ARPDMessage.ARPDAnswer received)
    {
        ARPDMessage.ARPD_MESSAGE_TYPE type_sent=received.getMsg_type();
        
                    //GENERAL CHECKS
        
        if(null == type_sent)
            return false;//problem !
        //check validity of signature and ...
        long timestamp_now=System.currentTimeMillis();
        boolean good=received.getSuffix().isValid(server.passwd,timestamp_now);
        if(!good)
            return false;//bad msg !
        //Check the type(here only start/stop) of message
        ARPDSessionState expected_state_before_answer=null;
        switch (type_sent) {
            case ANSWER_ACK_START:
                expected_state_before_answer=START_ORDERED;
                break;
            case ANSWER_ACK_STOP:
                expected_state_before_answer=STOP_ORDERED;
                break;
            default:
                return false;//problem !
        }
        //if we received a confirmation
        if(! received.answer_is_1_confirmation_is_0)
            return false;//problem: the slave is only supposed to send answers never confirmations !
        
                    //CONTENT GATHERING from inside the received message
        
        //we received an answer and we send a confirmation but the message type 
        //of our confirmation is ANSWER as well !
        //the only difference is the boolean answer_is_1_confirmation_is_0
        ARPDMessage.ARPD_MESSAGE_TYPE answer_type=type_sent;
        MACAddress mac_slave=received.getMAC_src();
        int rcv_order_nb=received.getSuffix().getNoonce();        
        //get the slave's address
        Inet4Address addr_slave_received=received.getIP_src();
        int slave_port=ARDP_SLAVE_PORT;
        DestIPInfo dest_slave=new DestIPInfo(addr_slave_received,slave_port);
        
        
        
	mess_logger.log(Level.INFO,"Received ANSWER:\n"+received.toString(0, server.passwd,System.currentTimeMillis()));
        
        
        
                    //SESSION and ORDER_NB verification & handling
        
        //from the address get the corresponding session (or create one if needed)
        ARPDSessionTableContainer session_table=server.getSessionTable();
        ARPDSession session_corresponding_to_received_msg=session_table.getSessionWith(dest_slave);
        if(session_corresponding_to_received_msg==null)
        {
            session_corresponding_to_received_msg= new ARPDSession(server,dest_slave);
            session_table.addARPDSession(session_corresponding_to_received_msg);
        }
        //if the session is somehow in an invalid state (or has been newly created...)
        //we use the info inside the message to reset it ot a valid state
        if(! session_corresponding_to_received_msg.isValid())
        {
            session_corresponding_to_received_msg.resetSession();
            session_corresponding_to_received_msg.setCurrentOrderId(rcv_order_nb);
            session_corresponding_to_received_msg.setCurrentState(expected_state_before_answer);
        }
        //else=if it's valid check the order_nb 
        //only drop if older order, not newer than expected !
        else if(rcv_order_nb<session_corresponding_to_received_msg.getCurrentOrderId())
        {   //debug only
            action_logger.log(Level.FINER, "Received answer from slave"+addr_slave_received+"\n\tBut the order nb is "+rcv_order_nb+" and we expected "+session_corresponding_to_received_msg.getCurrentOrderId()+"\n\tWill drop the msg");
            return true;
        }
        else if(! ARPDSessionState.areBothStartOrBothStop(expected_state_before_answer, session_corresponding_to_received_msg.getCurrentState()))
        {   //debug only
            action_logger.log(Level.WARNING, "Received answer from slave"+addr_slave_received+"\n\tWEIRD part : a GOOD order_nb BUT the msg's state nb is "+expected_state_before_answer.getConfirmedState()+" and we expected "+session_corresponding_to_received_msg.getCurrentState()+"\n\tWill drop the msg");
            return true;
        }
                
        
                        //CREATION of the CONFIRMATION
        
        ARPDMessage.ARPDAnswer confirmation_to_send= new ARPDMessage.ARPDAnswer
        (answer_type,false,src_ip_info.getIp_src(),src_ip_info.getMac_src(),rcv_order_nb,server.passwd);
        
                        //HANDLING whether or not we need to act on the message (activate/deactivate ARPdetox)
                        //or only send another confirmation because the first one got lost

        //if this is the first time we receive this confirmation_to_send (and not a duplicate 
        // because we were too slow to confirmation_to_send)
        ARPDSessionState currently_stored_session_state=session_corresponding_to_received_msg.getCurrentState();
        if(currently_stored_session_state.isInUnconfirmedButValidState())
        {
            action_logger.log(Level.INFO, "Received answer from slave"+addr_slave_received+"->"+mac_slave.toString()+"=>"+type_sent+"\n\tWill start/stop ARPDetox and send confirmation now");
            //TODO START/STOP COUNTERMEASURE !
            if(type_sent==ANSWER_ACK_START)
                ARPDetoxCountermeasure.addStaticEntry(addr_slave_received, mac_slave);
            else
                ARPDetoxCountermeasure.removeStaticEntry(addr_slave_received);
            //set the state to the corresponding confirmed state
            session_corresponding_to_received_msg.setCurrentState(currently_stored_session_state.getConfirmedState());
            
            
            mess_logger.log(Level.INFO,"Sent CONFIRMATION:\n"+confirmation_to_send.toString(0, server.passwd,System.currentTimeMillis()));
        
            
            ARPDBroadcastSession br_session=this.server.getBroadcastSession();
            if(br_session.getCurrentOrderId()== session_corresponding_to_received_msg.getCurrentOrderId() && br_session.getCanStopBroadcastBasedOnAnswersSoFar())
                br_session.stopLoopMessage();
        }
        else
        {
            action_logger.log(Level.FINER, "Received answer from slave"+addr_slave_received+"->"+mac_slave.toString()+"=>"+type_sent+"\n\tBut this is just a duplicate\n\tWill send confirmation now");
        }
        //only send the confirmation once, will get sent again if we receive another confirmation_to_send from the 
        //same slave
        session_corresponding_to_received_msg.sendSingleMessage(confirmation_to_send.toBytes());
        return true;
    }

    @Override
    public void callback(byte[] bytes_received)
    {
        if(bytes_received==null ||  bytes_received.length<1)
        {
            dumpMsg(bytes_received);
            return;
        }
        
        boolean correctly_handled=false;
        //RECEIVE
        try
        {
            ARPDMessage.ARPD_MESSAGE_TYPE type_sent=getMsgTypeFromBytes(bytes_received);
            if(type_sent.getAssociatedClass()== ARPDMessage.ARPDAnswer.class)
            {
                correctly_handled=handleAnswer(ARPDMessage.fromBytes(type_sent,bytes_received));
            }

        } catch (UnknownHostException | InvalidParameterException ex) 
        {        }
        if(!correctly_handled)
            dumpMsg(bytes_received);
    }
    
   
    
    @Override
    public void run()
    {
        ArrayBlockingQueue<byte[]> queue=server.getQueue_read();
        //the session table's container with the messages& the lock
        ARPDSessionTableContainer session_table_container=server.getSessionTable();
        //it's content: the actual table with the messages waiting
        ArrayList<ARPDSession> session_table=session_table_container.getContent();
	ARPDBroadcastSession broadcast_session=server.getBroadcastSession();
        while(server.isRunning())
        {
            //read messages and callback()
            try
            {
                byte[] buff=queue.poll(TIMEOUT_CONSUMER_THREAD, TIMEOUT_UNIT);
                if(buff!=null && buff.length>=1)
                    callback(buff);
            }catch(InterruptedException ie){}
            
            //try to write messages stored in the sessions
            boolean got_lock=session_table_container.getLock().readLock().tryLock();
            try
            {
                if(got_lock)
                {
                    //loop on all the sessions and send message if there's one waiting
                    for(int i=0;i<session_table.size();i++)
                    {
                        session_table.get(i).SendMessageIfDirectlyPossible(server);
                    }
                }
            }
            finally
            {
                if(got_lock)
                    session_table_container.getLock().readLock().unlock();
            }
	    //try to write messages stored in the broadcast session
            got_lock=broadcast_session.getSession_reentrant_lock().tryLock(); 
            try
            {
                if(got_lock)
                {
		    broadcast_session.SendMessageIfDirectlyPossible(server);                    
                }
            }
            finally
            {
                if(got_lock)
                    broadcast_session.getSession_reentrant_lock().unlock();
            }
            
        }
    }
    
    
        @Override
        public void dumpMsg(byte[] bytes_received)
    {
         if(bytes_received==null ||  bytes_received.length<1)
        {
            action_logger.log(Level.WARNING, "Null or empty message received");
            return;
        }
        //Try to cast it as an ARPDMessage
        try
        {
            ARPDMessage.ARPD_MESSAGE_TYPE type_sent=getMsgTypeFromBytes(bytes_received);
            ARPDMessage mess=ARPDMessage.fromBytes(type_sent,bytes_received);
            action_logger.log(Level.WARNING, "Could not handle the following ARPDMessage message :\n"+mess.toString(0,server.passwd,System.currentTimeMillis()));
        } catch (UnknownHostException | InvalidParameterException ex) 
        {
            action_logger.log(Level.WARNING, "Could not cast the following as ARPDMessage, dumping :\n"+bytesToHex(bytes_received)+"\nReason:\n");
            action_logger.log(Level.WARNING, null, ex);
        }
    }

}
