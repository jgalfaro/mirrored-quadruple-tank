/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package arpdetox_lib;

import static arpdetox_lib.ARPDMessage.ARPD_MESSAGE_TYPE.ANSWER_ACK_START;
import static arpdetox_lib.ARPDMessage.ARPD_MESSAGE_TYPE.ANSWER_ACK_STOP;
import static arpdetox_lib.ARPDMessage.ARPD_MESSAGE_TYPE.ORDER_START_ARPD;
import static arpdetox_lib.ARPDMessage.ARPD_MESSAGE_TYPE.ORDER_STOP_ARPD;
import static arpdetox_lib.ARPDMessage.bytesToHex;
import static arpdetox_lib.ARPDMessage.getMsgTypeFromBytes;
import arpdetox_lib.ARPDServer.*;
import static arpdetox_lib.ARPDServer.ARDP_MASTER_PORT;
import arpdetox_lib.ARPDSession.ARPDSessionState;
import static arpdetox_lib.ARPDSession.ARPDSessionState.*;
import arpdetox_lib.ARPDSessionContainer.*;
import static arpdetox_lib.ConsumerRunnable.TIMEOUT_CONSUMER_THREAD;
import arpdetox_lib.IPInfoContainers.DestIPInfo;
import java.net.Inet4Address;
import java.net.UnknownHostException;
import java.security.InvalidParameterException;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.logging.Level;
import java.util.logging.Logger;
import static arpdetox_lib.ConsumerRunnable.action_logger;

/**
 *
 * @author will
 */
public class ARPDSlaveConsumerRunnable extends ConsumerRunnable<ARPDServerSlave>
{
    public boolean handleOrder(ARPDMessage.ARPDOrder received)
    {
        action_logger.log(Level.SEVERE,"Message received!");
        ARPDMessage.ARPD_MESSAGE_TYPE type_sent=received.getMsg_type();
        
                    //GENERAL CHECKS
        
        if(null == type_sent)
            return false;//problem !
        //check if the message is for us or not (all orders are sent as broadcast !)
        Inet4Address addr_dst_received=received.getIP_dst();
        boolean primary_dst=addr_dst_received.equals(src_ip_info.getIp_src());
        boolean secondary_dst= !primary_dst && received.isEveryone_acts_or_only_dst();
        if(!primary_dst  && !secondary_dst)
        {
            action_logger.log(Level.INFO,"Message received, but it's not for us");
            return true;//not a message for us
        }
        //check validity of signature and ...
        long timestamp_now=System.currentTimeMillis();
        boolean good=received.getSuffix().isValid(server.passwd,timestamp_now);
        if(!good)
            return false;//bad msg !
        //select the type of msg we will send back based on the type of order
       ARPDMessage.ARPD_MESSAGE_TYPE answer_type=null;
       ARPDSessionState new_expected_state=null;
        switch (type_sent) {
            case ORDER_START_ARPD:
                new_expected_state=START_ANSWERED;
                answer_type=ANSWER_ACK_START;
                break;
            case ORDER_STOP_ARPD:
                new_expected_state=STOP_ANSWERED;
                answer_type=ANSWER_ACK_STOP;
                break;
            default:
                return false;//problem !
        }
        
        
        
        
	mess_logger.log(Level.INFO,"Received ORDER:\n"+received.toString(0, server.passwd,System.currentTimeMillis()));
        
        
        
        
                    //CONTENT GATHERING from inside the received message
        
        //get the master's address
        Inet4Address addr_master_received=received.getIP_src();
        ARPDMessage.MACAddress mac_master=received.getMAC_src();
        int rcv_order_nb=received.getSuffix().getNoonce();
        int master_port=ARDP_MASTER_PORT;
        DestIPInfo dest_info=new DestIPInfo(addr_master_received,master_port);
        //TODO STORE the master's MAC address to be used in the ARPdetox (a/dea)ctivation !
        
                    //SESSION and ORDER_NB compliance (we are a slave, once we verify
                    //the order does come from our master, we do what we are 
                    //told , no questions asked)
        ARPDSingleSessionContainer session_container=this.server.getSingleSessionContainer();
        //updateSessionIfNeeded will insure that the session is in a valid state
        boolean changed_it=updateSessionIfNeeded(dest_info,rcv_order_nb,new_expected_state);
        ARPDSession current_slave_session=session_container.getContent();
        
        
        //TODO : add the RANDOM SLEEP if we are secondary dst !
        
        
                    //CREATION of the ANSWER
        
        
        ARPDMessage.ARPDAnswer answer_to_send= new ARPDMessage.ARPDAnswer
        (answer_type,true,src_ip_info.getIp_src(),src_ip_info.getMac_src(),rcv_order_nb,server.passwd); 
        

                    //HANDLING whether or not we need to act on the message (activate/deactivate ARPdetox)
                    //or only send another answer_to_send because the first one got lost
                    
        //if this is the first time we receive this order (and not a duplicate 
        // because we were too slow to send the answer)
        if(changed_it)
        {
            action_logger.log(Level.INFO, "Received order from Master"+addr_master_received+"->"+mac_master.toString()+"=>"+type_sent+"\n\tWill start/stop ARPDetox and send answer now");
            //TODO START/STOP COUNTERMEASURE !
            if(type_sent==ORDER_START_ARPD)
                ARPDetoxCountermeasure.addStaticEntry(addr_master_received, mac_master);
            else
                ARPDetoxCountermeasure.removeStaticEntry(addr_master_received);
        }
        else
        {
            action_logger.log(Level.FINER, "Received order from Master"+addr_master_received+"\n\tBut this is just a duplicate\n\tWill send answer now");
        }
        //send the answer in a loop until we get a confirmation
        
	mess_logger.log(Level.INFO,"Sent ANSWER:\n"+answer_to_send.toString(0, server.passwd,System.currentTimeMillis()));
        
        current_slave_session.sendLoopMessage(answer_to_send.toBytes());
        return true;
    }
    
    public boolean updateSessionIfNeeded(DestIPInfo ip_info_master,int order_nb,ARPDSessionState state)
    {
        ARPDSession current_session=this.server.getSingleSessionContainer().getContent();
        boolean change_it=false;
        if(current_session==null
                || ! current_session.isValid()
                || ! current_session.getDst_ip_info().equals(ip_info_master) )
        {//dest_ip_info is final, we need to create a new session to change it
            current_session=new ARPDSession(this.server,ip_info_master);    
            change_it=true;
            this.server.getSingleSessionContainer().setARPDSession(current_session);
        }
        
        if (change_it 
                || current_session.getCurrentOrderId() != order_nb
                || ! ARPDSessionState.areBothStartOrBothStop(current_session.getCurrentState(), state))
        {
            current_session.resetSession();
            current_session.setCurrentOrderId(order_nb);
            current_session.setCurrentState(state);
            return true;
        }
        return false;
        
    }

    public boolean handleConfirmation(ARPDMessage.ARPDAnswer received)
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
        //select the type of msg we will send back based on the type of order
        ARPDMessage.ARPD_MESSAGE_TYPE answer_type=null;
        ARPDSessionState new_expected_state=null;
        switch (type_sent) {
            case ANSWER_ACK_START:
                new_expected_state=START_ANSWERED;
                answer_type=ANSWER_ACK_START;
                break;
            case ANSWER_ACK_STOP:
                new_expected_state=STOP_ANSWERED;
                answer_type=ANSWER_ACK_STOP;
                break;
            default:
                return false;//problem !
        }        
        //if we received an answer instead of a confirmation
        if(received.answer_is_1_confirmation_is_0)
            return false;//problem: the master is only supposed to send orders & confirmations !
        
        
        
	mess_logger.log(Level.INFO,"Received CONFIRMATION:\n"+received.toString(0, server.passwd,System.currentTimeMillis()));
        
        
                    //CONTENT GATHERING from inside the received message
        
        //get the master's address
        Inet4Address addr_master_received=received.getIP_src();
        int rcv_order_nb=received.getSuffix().getNoonce();
        int master_port=ARDP_MASTER_PORT;
        DestIPInfo dest_info=new DestIPInfo(addr_master_received,master_port);
        
                    //SESSION and ORDER_NB verification & handling
        boolean corresponds_session=checkIfCorrespondsToCurrentSession(dest_info,rcv_order_nb,new_expected_state);
        if(corresponds_session)
        {
            action_logger.log(Level.INFO, "Received confirmation from Master"+addr_master_received+"=>"+type_sent+"\n\tWill stop sending answers now");
            server.getSingleSessionContainer().getContent().stopLoopMessage();
        }
        else
        {
            action_logger.log(Level.WARNING, "Received confirmation from Master"+addr_master_received+"\nBUT we never received the corresponding order beforehand (nor sent an answer)\n\tWill drop the packet");
        }
        return true;
    }
    
        
    public boolean checkIfCorrespondsToCurrentSession(DestIPInfo ip_info_master,int order_nb,ARPDSessionState state)
    {
        ARPDSession current_session=this.server.getSingleSessionContainer().getContent();
        if(
                   current_session==null
                || ! current_session.isValid()
                || ! current_session.getDst_ip_info().equals(ip_info_master)
                || current_session.getCurrentOrderId() != order_nb
                || ! ARPDSessionState.areBothStartOrBothStop(current_session.getCurrentState(), state))
        {
            return false;
        }
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
            if(type_sent.getAssociatedClass()== ARPDMessage.ARPDOrder.class)
            {
                correctly_handled=handleOrder(ARPDMessage.fromBytes(type_sent,bytes_received));
            }
            else // it's an answer_to_send (confirmation normally even)
            {
                correctly_handled=handleConfirmation(ARPDMessage.fromBytes(type_sent,bytes_received));
            }

        } catch (UnknownHostException | InvalidParameterException ex){}
        if(!correctly_handled)
            dumpMsg(bytes_received);
    

    }

        @Override
    public void run()
    {
        ArrayBlockingQueue<byte[]> queue=server.getQueue_read();
        //the session's container with the message& the lock
        ARPDSingleSessionContainer single_session_container=server.getSingleSessionContainer();
        while(server.isRunning())
        {
            //read messages and callback()
            try
            {
                byte[] buff=queue.poll(TIMEOUT_CONSUMER_THREAD, TIMEOUT_UNIT);
                if(buff!=null && buff.length>=1)
                    callback(buff);
            }catch(InterruptedException ie){}

            //try to write messages stored in the session
            boolean got_lock=single_session_container.getLock().readLock().tryLock();
            try
            {
                if(got_lock && single_session_container.getContent() !=null)
                {
                    single_session_container.getContent().SendMessageIfDirectlyPossible(server);
                }
            }
            finally
            {
                if(got_lock)
                    single_session_container.getLock().readLock().unlock();
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
