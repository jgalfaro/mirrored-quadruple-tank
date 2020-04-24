/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package common;

import java.io.IOException;
import org.openmuc.j60870.CauseOfTransmission;
import org.openmuc.j60870.Connection;
import org.openmuc.j60870.ConnectionEventListener;
import org.openmuc.j60870.IeQualifierOfInterrogation;
import org.openmuc.j60870.IeSingleCommand;
import org.openmuc.j60870.IeTime56;
import org.openmuc.j60870.internal.cli.IntCliParameter;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.concurrent.TimeoutException;
import org.openmuc.j60870.ClientConnectionBuilder;
import org.openmuc.j60870.internal.cli.CliParameterBuilder;
import org.openmuc.j60870.internal.cli.StringCliParameter;

/**
 *
 * @author Will
 */
public abstract class ConnectionManager implements ConnectionEventListener {
    
    protected StringCliParameter host_param;
    protected IntCliParameter port_param;        
    protected IntCliParameter commonAddrParam;
    
    protected static int instance_counter=0;
    protected LockedLogger locked_logger;
    
    protected Connection connection;    
    protected boolean silence;
    
       
    protected boolean startConnection(){
        
	InetAddress target_address;
	Connection target_connection;
        try {
            target_address = InetAddress.getByName(host_param.getValue());
        } catch (UnknownHostException e) {
            System.out.println("Unknown host: ("+host_param.getValue()+")" + host_param.getValue());
            return false;
        }

        ClientConnectionBuilder clientConnectionBuilder = new ClientConnectionBuilder(target_address)
                .setPort(port_param.getValue());
        
        //establish Connection 
        try {
            target_connection = clientConnectionBuilder.connect();
        } catch (IOException e) {
            System.out.println("Unable to connect to remote host ("+host_param.getValue()+"): " + host_param.getDescription() + ".");
            return false;
        }	
	
	//set the established conenction in the connectionManager
	setConnection(target_connection);
	
        //Starting data transfer
        try {
            target_connection.startDataTransfer(this, 5000);
        } catch (TimeoutException e2) {
            System.out.println("Starting data transfer commonAddrParamr timed out. Closing connection with  "+host_param.getValue()+" .");
            target_connection.close();
            return false;
        } catch (IOException e) {
            System.out.println("Connection with "+host_param.getValue()+" closed for the following reason: " + e.getMessage());
	    target_connection.close();
            return false;
        }
        System.out.println("successfully connected to  "+host_param.getValue());
	return target_connection != null;	
    }
    
    
    public void sendSynchronizeClock(){
	
	if(connection==null)
	    return;
        printNewLine();
	printWithName("** Sending synchronize clocks command. ** ");
	try {
		    connection.synchronizeClocks(commonAddrParam.getValue(), new IeTime56(System.currentTimeMillis()));
	} catch (IOException e1) {
		    e1.printStackTrace();
	}	
    }
    
    
    public void sendInterrogationCommand(){
	
	if(connection==null)
	    return;
        printNewLine();
	printWithName("** Sending general interrogation command **");
	try {
		connection.interrogation(commonAddrParam.getValue(), CauseOfTransmission.ACTIVATION,
			new IeQualifierOfInterrogation(20));
	} catch (IOException e1) {
		e1.printStackTrace();
	}
    }
    
    public void sendCloseConnection(){
	if(connection==null)
	    return;
        printNewLine();
	printWithName("** Closing connection. **");
	connection.close();
        connection=null;
    }
    
    public void sendStopServer(){        
        if(connection==null)
	    return;
        printNewLine();
	printWithName("** Sending Shutdown server command **");
	try {
		connection.singleCommand(commonAddrParam.getValue(),
                        CauseOfTransmission.DEACTIVATION,
                        0, new IeSingleCommand(false,0,false));
	} catch (IOException e1) {
		e1.printStackTrace();
	}    
    }
    
    
    
    
    /****************************************/
    /****************************************/
    /****************************************/
    
    protected StringCliParameter getNewHostParameter(String IP_address){
	StringCliParameter target_host_param= new CliParameterBuilder("-h").buildStringParameter("host",IP_address );
	return target_host_param;
    }
    
    protected IntCliParameter getNewPortParameter(int port){
	IntCliParameter target_port_param= new CliParameterBuilder("-p")
            .setDescription("The port to connect to.").buildIntParameter("port", port);
	return target_port_param;
    }
    
    protected IntCliParameter getNewCommonAddressParameter(int common_address){
	IntCliParameter target_common_addr_param= new CliParameterBuilder("-ca")
            .setDescription("The address of the target station or the broad cast address.")
            .buildIntParameter("common_address", common_address);
	return target_common_addr_param;
    }
    
    public boolean isSilence() {
        return silence;
    }

    public void setSilence(boolean silence) {
        this.silence = silence;
    }
      

    public Connection getConnection() {
	return connection;
    }

    public void setConnection(Connection connection) {
	this.connection = connection;
    }
    
    public void printNewLine()
    {
        if(! silence)
            System.out.println();
    }   
    
    public void printWithName(String msg)
    {
        if(! silence)
            System.out.println(host_param.getValue()+"::"+msg);
    }
    
}
