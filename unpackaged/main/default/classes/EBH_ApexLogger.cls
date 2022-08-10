/*********************************************************************************************************************************
@ Class:          EBH_ApexLogger
@ Version:        1.0
@ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
@ Purpose:        Static Class to log apex exception/errors
                  EPH-5, EPH-6, EPH-21 : Generic apex exception log
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.05.2017 / JOY MONDOL / Created the class.
@				: 20.06.2018/ Vadhanak Voun / added asyn method
*********************************************************************************************************************************/

public class EBH_ApexLogger {
    
    /*****************************************************************************************************************************
    @ Method:         logError
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        Utility method to insert the exceptions to the Apex Log Object.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      exceptions: List of Exceptions
                      className:  Class name
                      methodName: Method name
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 07.09.2017 / JOY MONDOL / Created the  Method.
    *****************************************************************************************************************************/
    public static void logError(List<Exception> exceptions, String className, String methodName) {
        
        List<EBH_ApexLog__c> logs = new List<EBH_ApexLog__c>();
        
        for(Exception ex : exceptions) {
            logs.add(
                new EBH_ApexLog__c(
                    EBH_ClassName__c                 = className,
                    EBH_MethodName__c                = methodName,
                    EBH_ExceptionCause__c            = String.valueOf(ex.getCause()),
                    EBH_ExceptionLineNumber__c       = ex.getLineNumber(),
                    EBH_ExceptionStackTraceString__c = ex.getStackTraceString(),
                    EBH_ExceptionType__c             = ex.getTypeName(),
                    EBH_Message__c                   = (ex.getMessage()).length()> 255?(ex.getMessage()).substring(0,255): ex.getMessage()));
        }
        
        if(!logs.isEmpty()) {
            insert logs;
        }
    }
    
    /*****************************************************************************************************************************
    @ Method:         logError
    @ Version:        1.0
    @ Author:         JOY MONDOL (jmondol@deloitte.co.uk)
    @ Purpose:        Overloaded utility method to insert the database errors to the Apex Log Object.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      errors:     List of Errors
                      className:  Class name
                      methodName: Method name
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 07.09.2017 / JOY MONDOL / Created the  Method.
    @ Change history: 15.07.2022 / Sophal Noch / US-0011996 modify method
    *****************************************************************************************************************************/
    public static void logError(List<Database.Error> errors, String className, String methodName) {
        
        List<EBH_ApexLog__c> logs = new List<EBH_ApexLog__c>();
        
        for(Database.Error err : errors) {
            logs.add(new EBH_ApexLog__c(
                    EBH_ClassName__c     = className,
                    // EBH_Message__c    = err.getMessage(), // 15.07.2022 / Sophal Noch / US-0011996
                    EBH_Message__c       = ((err.getMessage()).length()> 255?(err.getMessage()).substring(0,255): err.getMessage()), // 15.07.2022 / Sophal Noch / US-0011996
                    EBH_MethodName__c    = methodName,
                    EBH_StatusMessage__c = String.valueOf(err.getFields())));
        }
        
        if(!logs.isEmpty()) {
            insert logs;
        }
    }
	
	/*****************************************************************************************************************************
    @ Method:         logError
    @ Version:        1.0
    @ Author:         Vadhanak Voun (vadhanak.voun@gaea-sys.com)
    @ Purpose:        Utility method to insert the exceptions to the Apex Log Object as asynchronous mode.
    ------------------------------------------------------------------------------------------------------------------------------
    @ Parameter:      exceptions: List of Exceptions
                      className:  Class name
                      methodName: Method name
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history: 20.06.2018 / Vadhanak Voun / Created the  Method.
    *****************************************************************************************************************************/
    @future
    public static void logError(String errCause,Integer lineNumber,String stackTrace,String errType,String errorMsg, String className, String methodName) {
        
        List<EBH_ApexLog__c> logs = new List<EBH_ApexLog__c>();
         
        logs.add(
            new EBH_ApexLog__c(
                EBH_ClassName__c                 = className,
                EBH_MethodName__c                = methodName,
                EBH_ExceptionCause__c            = errCause,
                EBH_ExceptionLineNumber__c       = lineNumber,
                EBH_ExceptionStackTraceString__c = stackTrace,
                EBH_ExceptionType__c             = errType,
                EBH_Message__c                   = (errorMsg).length()> 255?(errorMsg).substring(0,255): errorMsg));
        
        
        if(!logs.isEmpty()) {
            insert logs;
        }
    }
}