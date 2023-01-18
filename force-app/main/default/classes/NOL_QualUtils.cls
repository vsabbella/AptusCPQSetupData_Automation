/*
    Name            : NOL_QualHelper
    Author          : Bhoopender Pal Singh
    Release         : 1.0
    Description     : This class contains business logics implementation
    Functionality   :   
    Created         : Oct-07-2019
                      
    Modification History:
    Date            Author                  Change  
    Oct 07, 2019    Bhoopender Pal Singh    GTMSER-2743: NOL - Multiple Sub-Questions, Multi-Select and Operators
*/

public class NOL_QualUtils {

    private static final String OP_EQUALS_TO = 'equals to';
    private static final String OP_NOT_EQUALS_TO = 'not equals to';
    private static final String OP_GREATER_THAN = 'greater than';
    private static final String OP_GREATER_THAN_OR_EQUALS_TO = 'greater than or equals to';
    private static final String OP_LESS_THAN = 'less than';
    private static final String OP_LESS_THAN_OR_EQUALS_TO = 'less than or equals to';
    private static final String OP_BETWEEN = 'between'; //Includes boundaries
    private static final String OP_STARTS_WITH = 'starts with'; //Case Sensitive
    public static final String LIST_VALUES_SEPARATOR = ';';

    /**
    * Author: Bhoopender Pal Singh
    * This method evaluates the expression with provided dynamic operator
    * @val1: this is LHS value of the expression
    * @val2: this is RHS value of the expression
    * @op: this is the Operator to evaluate the provided values with
    */
    public static Boolean evalOpeartorExpression(String val1, String val2, String op) {
        return evalOpeartorExpression(val1, val2, op, false, null);
    }

    /**
    * Author: Bhoopender Pal Singh
    * This method evaluates the expression with provided dynamic operator
    * @val1: this is LHS value of the expression
    * @val2: this is RHS value of the expression
    * @op: this is the Operator to evaluate the provided values with
    * @isValInList: are the values actually list of values
    * @listSeparator: the list values separator e.g. ';'
    */
    public static Boolean evalOpeartorExpression(String val1, String val2, String op, Boolean isValInList, String listSeparator) {
        system.debug('=======================val1 op val2: ' + val1 + ' ' + op + ' ' + val2);
        system.debug('=======================isValInList: ' + isValInList);
        system.debug('=======================listSeparator: ' + listSeparator);

        //Validate inputs
        if(String.isBlank(val1) || String.isBlank(val2) || String.isBlank(op)) {
            throw new InvalidArgumentsException();
        }

        //If any one values are not numeric whereas the Operator is numeric
        if(
            op.equals(OP_GREATER_THAN) && op.equals(OP_GREATER_THAN_OR_EQUALS_TO) && op.equals(OP_LESS_THAN) && op.equals(OP_LESS_THAN_OR_EQUALS_TO) 
                && ( !val1.isNumeric() || !val2.isNumeric() ) 
            
            ||
            
            // Correct Value Example: '200' between '100,300'
            op.equals(OP_BETWEEN) 
                && ( !val1.isNumeric() || !val2.contains(',') || val2.split(',').size() != 2 || !val2.split(',')[0].isNumeric()  || !val2.split(',')[1].isNumeric() ) ) {
            throw new IncompatibleValueOrOperatorException();
        }

        //
        Boolean opEvaluated;

        if(op.equals(OP_EQUALS_TO)) {
            
            if(isValInList) {
                List<String> val1List = val1.split(listSeparator);
                List<String> val2List = val2.split(listSeparator);
                
                val1List.sort();
                val2List.sort();

                opEvaluated = val1List.equals(val2List);

            } else {
                opEvaluated = val1.equalsIgnoreCase(val2);
            }

        } else if(op.equals(OP_NOT_EQUALS_TO)) {

            if(isValInList) {
                List<String> val1List = val1.split(listSeparator);
                List<String> val2List = val2.split(listSeparator);

                val1List.sort();
                val2List.sort();

                opEvaluated = !val1List.equals(val2List);

            } else {
                opEvaluated = !val1.equalsIgnoreCase(val2);
            }

        } else if(op.equals(OP_GREATER_THAN)) {
            opEvaluated = Integer.valueOf(val1) > Integer.valueOf(val2);

        } else if(op.equals(OP_GREATER_THAN_OR_EQUALS_TO)) {
            opEvaluated = Integer.valueOf(val1) >= Integer.valueOf(val2);

        } else if(op.equals(OP_LESS_THAN)) {
            opEvaluated = Integer.valueOf(val1) < Integer.valueOf(val2);

        } else if(op.equals(OP_LESS_THAN_OR_EQUALS_TO)) {
            opEvaluated = Integer.valueOf(val1) <= Integer.valueOf(val2);                

        } else if(op.equals(OP_BETWEEN)) {
            Integer leftBoundaryVal = Integer.valueOf(val2.split(',')[0]);
            Integer rightBoundaryVal = Integer.valueOf(val2.split(',')[1]);
            opEvaluated = Integer.valueOf(val1) >= leftBoundaryVal && Integer.valueOf(val1) <= rightBoundaryVal;

        } else if(op.equals(OP_STARTS_WITH)) {
            opEvaluated = val1.startsWithIgnoreCase(val2);

        } else {
            throw new OperatorNotSupportedException();
        }

        system.debug('=======================opEvaluated: ' + opEvaluated);
        return opEvaluated;
    }

    //GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual    
    public static Set<String> getNOLEnabledProducts() {
        Set<String> prodDigitalFormEnabledSet = new Set<String>();
        
        //Extract the available Products from picklist in NOL Template object
        Set<String> prodSet = new Set<String>();

        for(Schema.PicklistEntry pickListVal : NOL_Template__c.Product__c.getDescribe().getPicklistValues()){
            prodSet.add(pickListVal.getLabel());
        }     

        //GTMSER-2672: Create Qual Form for the Product only if it's enabled in Custom Settings and also available in Picklist on NOL Template
        //Extract the digital qual enabled products from Custom Settings
        Map<String, New_Product__c> newProductCustomSetting = New_Product__c.getAll();
    
        for(String prodName : newProductCustomSetting.keySet()) {

            if(newProductCustomSetting.get(prodName).Enable_Digital_Form__c && prodSet.contains(prodName)) {
                prodDigitalFormEnabledSet.add(prodName);
            }
        }
        system.debug('=======================: ' + prodDigitalFormEnabledSet);
        return prodDigitalFormEnabledSet;
    }

    //******************************* Exceptions ********************    
    public class OperatorNotSupportedException extends Exception{}
    public class InvalidArgumentsException extends Exception{}
    public class IncompatibleValueOrOperatorException extends Exception{}    
}