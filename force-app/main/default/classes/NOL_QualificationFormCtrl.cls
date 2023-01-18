/**********************************************************************
Name:   NOL_QualificationFormCtrl()
============================================================================================================
Purpose:                                                           
-------  
This class is created to call the methods to create a Prod Qual Form.
**********************************************************************************************

============================================================================================================
Functionality   : GTMSER-1066
============================================================================================================

============================================================================================================
History                                                           
-------                                                           
    VERSION     AUTHOR                  DATE           
    1.0 -       Amil Hussain            Aug-29-2019    
                Bhoopender Pal Singh    Sep-16-2019
                Bhoopender Pal Singh    Sep-26-2019
                Bhoopender Pal Singh    Oct-01-2019
                Amil Hussain            Oct-07-2019
                Bhoopender Pal Singh    Oct-09-2019
                Bhoopender Pal Singh    Oct-14-2019
                Amil Hussain            Oct-15-2019
                Bhoopender Pal Singh    Oct-15-2019
                Amil Hussain            Oct-19-2019
                Amil Hussain            Nov-04-2019
                Bhoopender Pal Singh    Nov-06-2019
                Bhoopender Pal Singh    Nov-13-2019     Code Refactored, Improved and also fixed GTMSER-3113
                Ratnakar Reddy          Mar-25-2019    URL link for FAQ in Product Qualification form GTMCLS-1839
                Parvathi Chunduri       Mar-17-2021 GTMCLS-855 RSD/RVP Should be able to update the Account Executive field in product Qualification page
                Mounika Challa          Apr-01-2021 GTMCLS-211 Product Qualification Process Enhancement
                Lakshey Mendiratta      June-24-2021 GTMSEC-245 Add "CSM + Renewals" profile to Hardcoded References to "Customer Success Manager" profile
    18.0 -      Ankit Gupta             Aug-12-2021  GTMCLS-2336  PQ - Introduce 'FAQ Link' and Public Cloud 'SKU Availability Matrix' link on PQ
    19.0        Sunit Maddali           Aug-11-2021  GTMCLS-2639  PQ - Implement system validation for AE/CBAE/ Pre Sales/ BDM and Power users
    20.0 -      Ankit Gupta             Aug-18-2021  GTMCLS-2336  PQ - Introduce 'FAQ Link' and Public Cloud 'SKU Availability Matrix' link on PQ (Requirement-2).
    21.0        Parvathi Chunduri       Sep-09-02021  GTMCLS-2823  PQ - PQ - Update 'Overall Product Qualification Status' based on Approval status #1 and #2 in digital PQ form
    22.0        Parvathi Chunduri       Oct-27-2021    GTMCLS-3194 GTMCLS-3166 PQ - (CR) Update the SFDC status based on the 'Overall Product Qualification Status' field from PQ form
    23.0        Khadarbasha Shaik       Jan-05-2021  GTMENT-8892 Grant 'Edit' access to 'Clarification Comments' section on 'Product Qualification Form' for BDM, AE and SC Profiles
    24.0        Amit Kumar              Mar-22-2022  GTMSER-7197 BDM/BDD rename changes
********************************************************************************/


public class NOL_QualificationFormCtrl {
    public Map<String,List<QualWrapper>> qualMap{get;set;}

    //GTMSER-2743: NOL - Multiple Sub-Questions, Multi-Select and Operators
    public Map<Id, list<NOL_Qual_Question_Response__c>> qIdToCriteriaListMap{get;set;}
    public Map<Id, list<Id>> qCriteriaIdToSubQIdListMap{get;set;}     
    public Map<Id, list<Id>> qIdToSubQIdMatchedCriteriaListMap{get;set;}
    public String answeredQSection{get;set;}
    public Id answeredQId{get;set;}
    public String productId{get;set;} //Get Product ID
    public Product_Detail__c product{get;set;} //To Get/Set Product
    public Integer deploymentCount{get;set;} //To Get/Set Count Number of Active Deployment
    public Opportunity productOpportunity{get;set;} // To Get/Set opportunity,account from Product
    public String qualOp{get;set;}
    public boolean isReadOnly{get;set;} // To check readonly page or not.
    public String cssClassForAeBdmPsSecAccess{get;set;} // css Class
    public String cssClassForclariCommentSecAccess{get;set;} // css Class for Clarification Comment Section Edit Access
    public String cssClassForProdReviewSection{get;set;} //Enale Product Review Section  
    public String currentStatuswithWorkday{get;set;}
    public Date customerLiveDate = Date.today();
    public String lastModifyBy{get;set;}
    public String lastModifyDate{get;set;}
    public String redirectFAQLink{get;set;} //GTMCLS-2336
    public Boolean showFAQLinkFlag{get;set;} //GTMCLS-2336 
    public String redirectSKUAvailabilityMatrix{get;set;} //GTMCLS-2336 (Requirement -2)
    /* Start GTMCLS-2639 */
    public String cssClassForAeSectionAccess{get;set;} 
    public String cssClassForBdmSectionAccess{get;set;} 
    public String cssClassForPsSectionAccess{get;set;}
    /* End GTMCLS-2639 */
    public Boolean createdDateFlag {get;set;} //GTMCLS-3166
    public String CreatedDate{get;set;} //GTMCLS-3166

    //GTMSER-2687: NOL - Qual Form UI Enhancements (i. e.Convert lists in "Account Details" to tables)
    public Map<String, List<ProductFunctionWrapper>> groupsByToProdFunctWraprListMap{get;set;}
    private static final String GROUP_BY_PROD_AREA_LABEL_PREFIX = 'Group: ';
    
    //GTMSER-1965 - AC#4 - Check Edit/Read permissions
    public Boolean isAccessible{get;set;}
    public Boolean isUpdateable{get;set;}
    
    //GTMSER-2687: NOL - Qual Form UI Enhancements (i. e.Convert lists in "Account Details" to tables)
    public Map<String, String> productSkuToProdName{get;set;}

    public boolean displayMessage{get;set;}
    public String loggedInProfileName{get;set;}
    public Id qualFormId;
    public boolean isError{get;set;}
    public boolean isRequiredQuestion{get;set;}
    public String errorMessage{get;set;}
    public String bdmOptions{get;set;}
    public String preSalesoptions{get;set;}
    public List<SelectOption> bdmFitOptionsList{get;set;} //GTMSER-2258
    public List<SelectOption> preSalesFitOptionsList{get;set;} //GTMSER-2258
    public String bdmFitSelected{get;set;}
    public String preSalesFitSelected{get;set;}
    
    //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    public String presalesFitReadOnlyClass{get;set;}
    public String bdmFitReadOnlyClass{get;set;}
    public static final String DISABLED_CLASS = 'disabled';
    public String presalesRecommendedFit{get;set;}
    public String bdmRecommendedFit{get;set;}
    public NOL_Qual_Form__c qualForm{get;set;} //To Track Last Modify By - GTMSER-2264
    public final String aeSection = 'Account Executive - Opportunity Details';
    public final String preSalesSection = 'PreSales - Product Assessment';
    public final String bdmSection = 'Services Executive - Services Assessment'; // GTMSER-7197
    public final String productServicescssClassForProdReviewSection = 'Product/Services Review - Scope & Considerations';
    public final String clarificationCommentSection = 'Clarification Comments';
    public boolean isValidPermissionSetAssigned{get;set;}

    public List<String> orderedSectionList{get;set;}//GTMSER-1066 UI Feedback Demo for Section Ordering

    public transient System.Savepoint spForSaveOperation;
    public transient System.Savepoint spForSubmitOperation;
    
    public NOL_QualificationFormCtrl(){        
        isReadOnly = true;
        cssClassForAeBdmPsSecAccess = 'disabled';
        cssClassForProdReviewSection = 'disabled';
        cssClassForclariCommentSecAccess = 'disabled';
        displayMessage = false;
        isError = false;
        isRequiredQuestion = false;
        isValidPermissionSetAssigned = false;
        
        orderedSectionList = new List<String>{aeSection,preSalesSection,bdmSection,clarificationCommentSection,productServicescssClassForProdReviewSection};
        
        init();
        loadQualFormPermissions();       
        getData();
    }
    //Initialization
    private void  init(){

        //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
        presalesFitReadOnlyClass = DISABLED_CLASS;
        bdmFitReadOnlyClass = DISABLED_CLASS;
        List<PermissionSetAssignment> userHasPermissionAssignedSets = null;
        
        loggedInProfileName = [SELECT id,Name FROM Profile WHERE id =: UserInfo.getProfileId()][0].Name;
        
        
        
        
        userHasPermissionAssignedSets = [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name in ('NOL_Program_Managers_Permission_Set','Product_Detail_Approver') and AssigneeId = : UserInfo.getUserId()];
        if(userHasPermissionAssignedSets != null && userHasPermissionAssignedSets.size()>0){
            isValidPermissionSetAssigned = true;
        }
        System.debug('userHasPermissionAssignedSets--->'+userHasPermissionAssignedSets);
        System.debug('isValidPermissionSetAssigned----->'+isValidPermissionSetAssigned);
        productId = ApexPages.currentPage().getParameters().get('Id');
        //productId = (String) controller.getRecord().id;

        //
        loadPQ();
        
        // GTMCLS-2336 - Start
        
        // Getting SKU & their respective FAQ Links from the Custom Setting ==> PQFAQLink__c
        List<PQFAQLink__c> lstPQFAQLink = PQFAQLink__c.getall().values();
        
        for(PQFAQLink__c pqfaq : lstPQFAQLink) {   
            if(pqfaq.name == product.Name){
               
                showFAQLinkFlag = true;
                redirectFAQLink = pqfaq.FAQ_Link__c;    
            }
            else if(product.Name == 'Answers'|| product.Name =='LDP Answers'|| product.Name == 'Help'|| product.Name == 'LDP Help'|| product.Name == 'Journeys'|| product.Name == 'LDP Journeys'|| product.Name == 'Moments'|| 
                    product.Name == 'LDP Moments'|| product.Name == 'People Analytics'|| product.Name == 'LDP People Analytics'||  product.Name == 'Workday Extend'||  product.Name == 'Talent Optimization') {
                        
                 showFAQLinkFlag = false;
                    }
        }
        
        
        // GTMCLS-2336 -- End 
        
        // GTMCLS-2336 -- Start (Requirement - 2)

      
        // Getting SKU & their respective FAQ Links from the Custom Setting ==> FAQLink__c
        List<FAQLink__c> lstFAQLink = FAQLink__c.getall().values();
        
        
        for(FAQLink__c faq : lstFAQLink) {   
            if(faq.name == product.Name){
                
                redirectSKUAvailabilityMatrix = faq.SKU_Availability_Matrix__c;    
            }
          
        }
       
        // GTMCLS-2336 -- End(Requirement - 2)

        
        //GTMSER-2264: NOL - Phase 2 - (#AC3)
        System.debug('Opportunity.Id'+product.Opportunity__c);
        
        productOpportunity = [SELECT Id, AccountId, Account.Name, Account.Type,Account.NumberOfEmployees,Account.Region__c,Account.Industry,
                                    Account.Initial_Go_Live_Date__c 
                                FROM Opportunity WHERE Id =: product.Opportunity__c LIMIT 1];
        
        if((productOpportunity.Account.Initial_Go_Live_Date__c == Null && productOpportunity.Account.Type == 'Customer') || productOpportunity.Account.Initial_Go_Live_Date__c > customerLiveDate){
            currentStatuswithWorkday = 'Signed';

        }else if(productOpportunity.Account.Initial_Go_Live_Date__c == Null && productOpportunity.Account.Type == 'Prospect'){
            currentStatuswithWorkday = 'Open';
            
        }else{
            currentStatuswithWorkday = 'Live';
        }
        
        deploymentCount = [SELECT Id FROM Deployments__c 
                           WHERE Customer__c =: productOpportunity.AccountId AND Overall_Status__c = 'Active'].size();

        //GTMSER-2687: NOL - Qual Form UI Enhancements (i. e.Convert lists in "Account Details" to tables)
        //Get Live Product Funtion        
        groupsByToProdFunctWraprListMap = new Map<String, List<ProductFunctionWrapper>>();        
        
        for(Deployment_Product_Function__c proLive : [SELECT Id, Product_Area_Name__c, Function__c , Production_Move_Date_Target__c, Production_Move_Date_Actual__c 
                                                      FROM Deployment_Product_Function__c 
                                                      WHERE Customer__c =: productOpportunity.AccountId]){
                                                          
            if(proLive.Production_Move_Date_Actual__c !=Null && currentStatuswithWorkday == 'Live'){                
                
                ProductFunctionWrapper prodFunctWrapper = new ProductFunctionWrapper();
                prodFunctWrapper.productArea = proLive.Product_Area_Name__c;
                prodFunctWrapper.productFunction = proLive.Function__c;

                //Target and Actual Dates
                String dateFormat = 'EEE MMM dd yyyy';
                prodFunctWrapper.targetDate = dateFormat(proLive.Production_Move_Date_Target__c, dateFormat);
                prodFunctWrapper.actualDate = dateFormat(proLive.Production_Move_Date_Actual__c, dateFormat);

                String groupByProdAreaLabel = GROUP_BY_PROD_AREA_LABEL_PREFIX + proLive.Product_Area_Name__c;

                if(groupsByToProdFunctWraprListMap.containsKey(groupByProdAreaLabel)) {
                    groupsByToProdFunctWraprListMap.get(groupByProdAreaLabel).add(prodFunctWrapper);
                } else {
                    groupsByToProdFunctWraprListMap.put(groupByProdAreaLabel, new List<ProductFunctionWrapper>{prodFunctWrapper});
                }
            }            
        }

        //GTMSER-2687: NOL - Qual Form UI Enhancements (i. e.Convert lists in "Account Details" to tables)
        //GTMSER-2509 #AC2 START
        productSkuToProdName = new Map<String, String>();
        
        for(Apttus_Config2__AssetLineItem__c productSku : [SELECT Id, Apttus_CMConfig__AgreementLineItemId__c, 
                                                                Apttus_CMConfig__AgreementLineItemId__r.Product_SKU__c, 
                                                                Apttus_CMConfig__AgreementLineItemId__r.Product_Name__c
                                                            FROM Apttus_Config2__AssetLineItem__c 
                                                            WHERE Apttus_Config2__AccountId__c =: productOpportunity.AccountId 
                                                                AND Apttus_Config2__AssetStatus__c = 'Activated']){
            
            if(productSku.Apttus_CMConfig__AgreementLineItemId__c != null){
              productSkuToProdName.put(productSku.Apttus_CMConfig__AgreementLineItemId__r.Product_SKU__c, productSku.Apttus_CMConfig__AgreementLineItemId__r.Product_Name__c);  
            }
        }       
        //GTMSER-2509 #AC2 END 
    }

    //To display all NOL Qual Question and corresponding  field with respect to Section
    private void  getData(){

        //GTMSER-2743: NOL - Multiple Sub-Questions, Multi-Select and Operators
        Map<Id, QualWrapper> qualQIdToWrapMap = new Map<Id, QualWrapper>();
        qIdToCriteriaListMap = new Map<Id, list<NOL_Qual_Question_Response__c>>();
        qCriteriaIdToSubQIdListMap = new Map<Id, list<Id>>();
        qIdToSubQIdMatchedCriteriaListMap = new Map<Id, list<Id>>();

        //PQ Data
        loadPQ(); 

        //Qual Form Data
        loadQualForm();

        qualFormId = qualForm.Id;
        lastModifyDate = qualForm.LastModifiedDate.format();
        
        //Start GTMCLS-3166
        CreatedDate = qualForm.CreatedDate.format(); 
        Date d = date.newInstance(2021, 10, 15); 
        if(qualForm.CreatedDate<=d){
            createdDateFlag = true;
        }
        //End GTMCLS-3166
        
        lastModifyBy =  qualForm.LastModifiedBy.Name + ', ' + lastModifyDate;

        //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Recommended Fit Calculations
        presalesRecommendedFit = qualForm.PreSales_Recommended_Fit__c;
        bdmRecommendedFit = qualForm.BDM_Recommended_Fit__c;

        //Custom Fit Values
        loadFitValues();

        //Custom Fit Permissions
        loadFitPermissions();

        //Expecting that the Order of Questions are provided and SubQuestions Order will always be after the Parent
        List<NOL_Qual_Question__c> qualQuestions = [SELECT Id,Section__c,Question_Title__c,Type__c,
                                                        Help_Text__c,Answer__c,                                                        
                                                        Parent_Question__c, Parent_Question_Criteria__c, Parent_Question_Criteria__r.Answer__c, Parent_Question_Criteria__r.Operator__c,
                                                        Order__c, PQ_Obj_Field_To_Sync_Ans__c, PQ_Obj_Field_To_Sync_Ans_When__c,
                                                        NOL_Qual_Form__r.Product_Qualification__c,NOL_Qual_Form__r.NOL_Template__c,
                                                        NOL_Qual_Form__r.Id,NOL_Qual_Form__r.Name,
                                                        (SELECT Id, Option__c FROM NOL_Qual_Question_Options__r),
                                                        (SELECT Id, NOL_Qual_Question__c, Answer__c, Operator__c, Score__c FROM NOL_Qual_Question_Scores__r)
                                                        FROM NOL_Qual_Question__c 
                                                        WHERE NOL_Qual_Form__r.Product_Qualification__c =:productId 
                                                        ORDER BY Order__c];        
        
        //GTMSER-2743: NOL - Multiple Sub-Questions, Multi-Select and Operators
        //Preapre Questions, SubQuestions and Criteria data to display
        for(NOL_Qual_Question__c qualQuestion : qualQuestions ){

            QualWrapper qualWrapper = new QualWrapper();
            qualWrapper.isFaqLinkAvail = qualQuestion.Question_Title__c == null ? false : qualQuestion.Question_Title__c.indexOf('FAQ LINK') != -1 ? true : false;
            //qualWrapper.questionTitle = qualQuestion.Question_Title__c == null ? '' : qualQuestion.Question_Title__c.remove('FAQ LINK') ;//GTMCLS-2336
            qualWrapper.questionType = qualQuestion.Type__c;
            qualWrapper.questionId = qualQuestion.Id;
            qualWrapper.helpText = qualQuestion.Help_Text__c;
            qualWrapper.answer = qualQuestion.Answer__c; 
            //2336
            qualWrapper.isSkuAvailabilityMatrixAvailable = qualQuestion.Question_Title__c == null ? false : qualQuestion.Question_Title__c.indexOf('sku availability matrix') != -1 ? true : false;  //GTMCLS -2336 (Requirement -2) 
            
            if( qualWrapper.isSkuAvailabilityMatrixAvailable == true)
            {
                qualWrapper.questionTitle = qualQuestion.Question_Title__c == null ? '' : qualQuestion.Question_Title__c.remove('sku availability matrix') ;
            
            }
            else {
                qualWrapper.questionTitle = qualQuestion.Question_Title__c == null ? '' : qualQuestion.Question_Title__c.remove('FAQ LINK') ;
            }
            //2336 ends
            //GTMSER-2870: Value for sub questions of type Multi-Select doesn't save
            qualWrapper.pqObjFieldToSyncAns = qualQuestion.PQ_Obj_Field_To_Sync_Ans__c;
            qualWrapper.pqObjFieldToSyncAnsWhen = qualQuestion.PQ_Obj_Field_To_Sync_Ans_When__c;
            //

            if(qualQuestion.Type__c.equals('Picklist')) {
                qualWrapper.optionsList = setPicklistOptions(qualQuestion.NOL_Qual_Question_Options__r, false);

            } else if(qualQuestion.Type__c.equals('Multi-Select')) {
                qualWrapper.optionsList = setPicklistOptions(qualQuestion.NOL_Qual_Question_Options__r, true);

                if(qualQuestion.Answer__c != null) {
                    qualWrapper.answerList = qualQuestion.Answer__c.split(';');
                }
            }

            qualWrapper.section = qualQuestion.Section__c;
            qualWrapper.isParent = false;

            //Criteria
            qIdToCriteriaListMap.put(qualQuestion.Id, qualQuestion.NOL_Qual_Question_Scores__r);
                        
            // If this is a Quetion i.e. NOT a SubQuestion
            if(qualQuestion.Parent_Question__c == null){

                //Set Visibility of Question
                qualWrapper.isVisible = true;
            
            // If this is a SubQuestion
            } else {
                
                //Set Visibility of SubQuestion
                QualWrapper qualWrapperParent = qualQIdToWrapMap.get(qualQuestion.Parent_Question__c);

                try {    

                    //Check if criteria matched
                    Boolean isCriteriaMatched;

                    if(qualWrapperParent.questionType.equals('Multi-Select')) {
                        isCriteriaMatched = NOL_QualUtils.evalOpeartorExpression(qualWrapperParent.answer, qualQuestion.Parent_Question_Criteria__r.Answer__c, qualQuestion.Parent_Question_Criteria__r.Operator__c, true, NOL_QualUtils.LIST_VALUES_SEPARATOR);
                    } else {
                        isCriteriaMatched = NOL_QualUtils.evalOpeartorExpression(qualWrapperParent.answer, qualQuestion.Parent_Question_Criteria__r.Answer__c, qualQuestion.Parent_Question_Criteria__r.Operator__c);
                    }
                    
                    //
                    if(isCriteriaMatched) {
                        qualWrapper.isVisible = true;

                        if(qIdToSubQIdMatchedCriteriaListMap.containsKey(qualQuestion.Parent_Question__c)) {
                            qIdToSubQIdMatchedCriteriaListMap.get(qualQuestion.Parent_Question__c).add(qualQuestion.Id);
                        } else {
                            qIdToSubQIdMatchedCriteriaListMap.put(qualQuestion.Parent_Question__c, new List<Id>{qualQuestion.Id});
                        }

                    } else {
                        qualWrapper.isVisible = false;
                    }
                } catch(NOL_QualUtils.InvalidArgumentsException e) {
                    qualWrapper.isVisible = false;
                }               
                
                system.debug('===================qIdToSubQIdMatchedCriteriaListMap: ' + qIdToSubQIdMatchedCriteriaListMap);

                //set parent question data
                qualWrapperParent.isParent = true;

                //SubQuestions list for the specified Criteria
                if(qCriteriaIdToSubQIdListMap.containsKey(qualQuestion.Parent_Question_Criteria__c)) {
                    qCriteriaIdToSubQIdListMap.get(qualQuestion.Parent_Question_Criteria__c).add(qualQuestion.Id);   
                } else {
                    qCriteriaIdToSubQIdListMap.put(qualQuestion.Parent_Question_Criteria__c, new List<Id>{qualQuestion.Id});   
                }               
            }

            qualQIdToWrapMap.put(qualQuestion.Id, qualWrapper);   
        }

        //Arrange Questions by Section
        qualMap = new Map<String, List<QualWrapper>>();

        for(Id qualQId : qualQIdToWrapMap.keySet()) {
            QualWrapper qualWrapper = qualQIdToWrapMap.get(qualQId);

            if(qualMap.containsKey(qualWrapper.section)){
                List<QualWrapper> qualList = qualMap.get(qualWrapper.section);
                qualList.add(qualWrapper);

            }else{
                qualMap.put(qualWrapper.section, new List<QualWrapper>{qualWrapper});
            } 
        }        
        
         //GTMCLS-2823 Starts
         if(qualMap.size() > 0) {
            string sectionHeader = 'Product/Services Review - Scope & Considerations';
            boolean status1Present = false;//GTMCLS-3194
            boolean status2Present = false;//GTMCLS-3194
            if(qualMap.containsKey(sectionHeader)) 
            {
                string status1 = '';
                string status2 = '';
                
                for(QualWrapper qw : qualMap.get(sectionHeader)) {
                   
                    if(qw.pqObjFieldToSyncAns.equalsignorecase('Approval_Status_1__c')) {
                        status1 = qw.answer;   
                        status1Present = true;
                    }
                   
                    if(qw.pqObjFieldToSyncAns.equalsignorecase('Approval_Status_2__c')) {
                        status2 = qw.answer;   
                        status2Present = true;
                    }
                  
                    if(qw.pqObjFieldToSyncAns.equalsignorecase('Status__c') && status1Present && status2Present) {
                        qw.answer = getOverallProdQualificationStatus(status1, status2);
                    }
                }
            }
        }
        
        //GTMCLS-2823 ends

        //To Fixed the section order - START 
        List<String> sectionListTemp = new List<String>();

        for(String sectionOrderedName: orderedSectionList){

            if(qualMap.containsKey(sectionOrderedName)){
                sectionListTemp.add(sectionOrderedName);
            }
            
        }

        orderedSectionList = sectionListTemp;
        //To Fixed the section order - END
    }

    private void loadPQ() {
        product = [SELECT Id,Name,Services_Customer_Fit__c,SC_indicates_customer_fit__c,Deployment_Considerations__c,Product_Considerations__c,
                        Clarification_Comments__c,Status__c,Opportunity__c,Opportunity__r.Name 
                    FROM Product_Detail__c WHERE Id =: productId LIMIT 1];
    }

    private void loadQualForm() {
    
        qualForm = [SELECT Id, Name, BDM_Fit__c, PreSales_Customer_Fit__c, BDM_Recommended_Fit__c, PreSales_Recommended_Fit__c, 
                            LastModifiedDate, LastModifiedBy.Name,CreatedDate //GTMCLS-3166
                    FROM NOL_Qual_Form__c WHERE Product_Qualification__c =: product.Id];
    }

    private List<SelectOption> setPicklistOptions(List<NOL_Qual_Question_Option__c> qualQOptionsList, Boolean isMultiSelect){

        List<SelectOption> optionsList = new List<SelectOption>();
        List<String> sortedOptionsList = new List<String>();

        if(!isMultiSelect) {
            optionsList.add(new SelectOption('', '--None--'));
        }

        for(NOL_Qual_Question_Option__c qOptionRec : qualQOptionsList){
            sortedOptionsList.add(qOptionRec.Option__c);                
        }

        sortedOptionsList.sort();

        for(String optionVal : sortedOptionsList){
            optionsList.add(new SelectOption(optionVal, optionVal));
        }

        return optionsList;
    }
    
    //*** This method is used to Edit the Prod Qual form.
    public void editPage(){
        
        //GTMSER-1350 START
        //initialize defaults
        cssClassForAeBdmPsSecAccess = 'disabled';
        cssClassForProdReviewSection = 'disabled';
        cssClassForclariCommentSecAccess = 'disabled'; //GTMSER-2703

         /* Start GTMCLS-2639 */
         cssClassForAeSectionAccess= 'disabled';
         cssClassForBdmSectionAccess= 'disabled';
         cssClassForPsSectionAccess='disabled';
          /* End GTMCLS-2639 */

        //Profile Level checks
        if(loggedInProfileName.equals('System Administrator') || 
            loggedInProfileName.equals('Data Administrator')  || 
            loggedInProfileName.equals('Services Ops') || 
            loggedInProfileName.equals('Services Ops Admin') || 
            loggedInProfileName.equals('Sales/Ops Admin') || 
            loggedInProfileName.equals('Renewals') || 
            loggedInProfileName.equals('Workday Integration') || 
            loggedInProfileName.equals(Label.CSM_Renewal_Profile) ) {               
            cssClassForAeBdmPsSecAccess = 'enabled';
            cssClassForProdReviewSection = 'enabled';
            cssClassForclariCommentSecAccess = 'enabled'; //GTMSER-2703

        //#AC5 and #AC6 START
        } else if(
                    //loggedInProfileName.equals('Account Executive')  || loggedInProfileName.equals('Solutions Consultant')  || loggedInProfileName.equals('Business Development Manager') || //GTMCLS-2639
                   loggedInProfileName.equals('Regional Sales Director') || 
                   loggedInProfileName.equals('Regional Vice President') || 
                   loggedInProfileName.equals('Corporate Sales Development') || 
                   loggedInProfileName.equals('Customer Success Manager') ||  
                   loggedInProfileName.equals(Label.CSM_Renewal_Profile) || 
                   loggedInProfileName.equals('Sales/Ops') || 
                   loggedInProfileName.equals('Sales/Ops Admin') || 
                   loggedInProfileName.equals('Renewals') || 
                   loggedInProfileName.equals('Workday Integration')  ){  //GTMCLS-855 //GTMSEC-245 Adding CSM+Renewals Profile Check                                                                 
            cssClassForAeBdmPsSecAccess = 'enabled';
            cssClassForclariCommentSecAccess = 'enabled';
        }
        
        // Permission Sets check
        if(isValidPermissionSetAssigned) {
            cssClassForProdReviewSection = 'enabled';                
            cssClassForclariCommentSecAccess = 'enabled'; //GTMSER-2703
        }

        /* Start GTMCLS-2639 */
        // Section Access for profiles - Account Executive - Opportunity Details
        if(loggedInProfileName.equals('System Administrator') || 
            loggedInProfileName.equals('Data Administrator')  || 
            loggedInProfileName.equals('Workday Integration') ||
            loggedInProfileName.equals('Renewals') || 
            loggedInProfileName.equals('Sales/Ops Admin') || 
            loggedInProfileName.equals(Label.CSM_Renewal_Profile) ||  
            loggedInProfileName.equals('Account Executive') ) 
            {  
                cssClassForAeSectionAccess = 'enabled';
                cssClassForclariCommentSecAccess = 'enabled'; //GTMENT-8892: Enable Clarification Comments access
            }
            // Section Access for profiles - PreSales - Product Assessment
        if(loggedInProfileName.equals('System Administrator') || 
            loggedInProfileName.equals('Data Administrator')  || 
            loggedInProfileName.equals('Workday Integration') || 
            loggedInProfileName.equals('Renewals') || 
            loggedInProfileName.equals('Sales/Ops Admin') || 
            loggedInProfileName.equals(Label.CSM_Renewal_Profile) ||  
            loggedInProfileName.equals('Solutions Consultant')  ) 
            {  
                cssClassForPsSectionAccess = 'enabled';
                cssClassForclariCommentSecAccess = 'enabled'; //GTMENT-8892: Enable Clarification Comments access
            }
            // Section Access for profiles - Services Executive - Services Assessment
        if(loggedInProfileName.equals('System Administrator') || 
            loggedInProfileName.equals('Data Administrator')  || 
            loggedInProfileName.equals('Workday Integration') || 
            loggedInProfileName.equals('Renewals') || 
            loggedInProfileName.equals('Sales/Ops Admin') || 
            loggedInProfileName.equals(Label.CSM_Renewal_Profile) || 
            loggedInProfileName.equals('Business Development Manager')  ) 
            {  
                cssClassForBdmSectionAccess = 'enabled';
                cssClassForclariCommentSecAccess = 'enabled'; //GTMENT-8892: Enable Clarification Comments access
            }

        /* End GTMCLS-2639 */



        //#AC3 and #AC4 START: Based on Custom Fit and Status values
        if(product.Services_Customer_Fit__c != null && product.SC_indicates_customer_fit__c != null) {

            if(product.Status__c == 'Approved - No Restrictions' || product.Status__c == 'Denied' || product.Status__c == 'Approved - With Restrictions') {
                cssClassForAeBdmPsSecAccess = 'disabled';
                cssClassForProdReviewSection = 'disabled';
                cssClassForclariCommentSecAccess = 'disabled'; //GTMSER-2703

            } else if(product.Status__c  != 'Clarification Needed') {
                cssClassForAeBdmPsSecAccess = 'disabled';
            }
        }
        //#AC3 and #AC4 END

        //GTMSER-1350 END
        isReadOnly = false;
        displayMessage = false;        
    }
    
    //*** This method is used to cancel the request.
    public void onCancelCall(){
        
        isReadOnly = true;
        cssClassForAeBdmPsSecAccess = 'disabled';
        cssClassForProdReviewSection = 'disabled';
        cssClassForclariCommentSecAccess = 'disabled'; //GTMSER-2703
        //qualMap = new Map<String, List<QualWrapper>>();
        qualMap.clear();//On cancel button qualMap should be empty

        displayMessage = false;
        isError = false;
        getData(); //On Cancel get old data
    }

    private String dateFormat(Date dateInstance, String dateFormat) {
        return DateTime.newInstance(dateInstance.year(), dateInstance.month(), dateInstance.day()).format(dateFormat);
    }
    
    //Date Calender
    public String userLocaleFormat{
        get{
            //GTMSER-3156: UAT - Date value is not being retained on the Qual Form
           //return CC_TimeUtil.userLocaleFormat(UserInfo.getLocale());
           return CC_TimeUtil.userLocaleFormat('en_US');
        }
    }

    //****** This method is used to save the changes after edit the page.
    public void saveRecords(){
        system.debug('=============saveRecords() started');
        isError = false;
        spForSaveOperation = Database.setSavepoint();
        List<NOL_Qual_Question__c> updatedAnswerList = new List<NOL_Qual_Question__c>();
        
        // GTMCLS-2823 start-------
        if(qualMap.size() > 0) {
            string sectionHeader = 'Product/Services Review - Scope & Considerations';
            boolean status1Present = false;//GTMCLS-3194
            boolean status2Present = false;//GTMCLS-3194
            if(qualMap.containsKey(sectionHeader)) 
            {
                string status1 = '';
                string status2 = '';
                
                for(QualWrapper qw : qualMap.get(sectionHeader)) {
                   
                    if(qw.pqObjFieldToSyncAns.equalsignorecase('Approval_Status_1__c')) {
                        status1 = qw.answer; 
                        status1Present = true;
                    }
                   
                    if(qw.pqObjFieldToSyncAns.equalsignorecase('Approval_Status_2__c')) {
                        status2 = qw.answer; 
                        status2Present = true;
                        
                    }
                    
                    if(qw.pqObjFieldToSyncAns.equalsignorecase('Status__c') && status1Present && status2Present) {
                        qw.answer = getOverallProdQualificationStatus(status1, status2);
                       
                    }
                }
            }
        }
        
        // ---GTMCLS-2823 end-------
        

        for(List<QualWrapper> qualWrapperList : qualMap.values()){

            for(QualWrapper qualWrapper : qualWrapperList)  {

                NOL_Qual_Question__c qualAnswerUpsert= new NOL_Qual_Question__c();
                qualAnswerUpsert.Id = (Id) qualWrapper.questionId;            

                if(qualWrapper.isVisible) {
                    
                    //GTMSER-2870: Value for sub questions of type Multi-Select doesn't save
                    if(qualWrapper.questionType.equals('Multi-Select')) {
                        qualAnswerUpsert.Answer__c = String.join(qualWrapper.answerList, ';');
                    } else {
                        qualAnswerUpsert.Answer__c = qualWrapper.answer;
                    }

                    //GTMSER-2703, 2906, 2916: Save answer in specified fields of PQ Object, if any
                    setAnsToSyncToPQ(qualWrapper);
                    //

                } else {
                    qualAnswerUpsert.Answer__c = '';
                }
                
                updatedAnswerList.add(qualAnswerUpsert);
            }
        }

        //Update Ansers and Recommended Fits
        if(updatedAnswerList.size()>0){
            upsert updatedAnswerList;
            
            //GTMSER-2916: Update Recommended Fits on PQ
            NOL_Qual_Form__c qualFormWithRecommendedFits = NOL_QualHelper.calculateRecommendedFits(qualFormId);
            system.debug('================qualFormWithRecommendedFits: ' + qualFormWithRecommendedFits);

            //Check Qual Form with Recommended Fits Saved Successfully.
            if(qualFormWithRecommendedFits != null) {

                //Qual Form
                qualForm.PreSales_Recommended_Fit__c = qualFormWithRecommendedFits.PreSales_Recommended_Fit__c;
                qualForm.BDM_Recommended_Fit__c = qualFormWithRecommendedFits.BDM_Recommended_Fit__c;

                //PQ
                /** Commented as part of  GTMCLS-211
                product.Recommended_PreSales_Fit__c = qualFormWithRecommendedFits.PreSales_Recommended_Fit__c;
                product.Recommended_BDM_Fit__c = qualFormWithRecommendedFits.BDM_Recommended_Fit__c;
                **/
            }
        }

        //Custom Fits
        qualForm.PreSales_Customer_Fit__c = preSalesFitSelected;
        qualForm.BDM_Fit__c = bdmFitSelected;

        isReadOnly = true;
        cssClassForAeBdmPsSecAccess = 'disabled';
        cssClassForProdReviewSection = 'disabled';
        cssClassForclariCommentSecAccess = 'disabled'; //GTMSER-2703
        displayMessage = true;
        
        Update qualForm;        
        updateProduct();        
        
        if(isError){
            editPage();
        }else{
           getData(); 
        }
        
        system.debug('=============saveRecords() finished');
    }

    // This method is used to save & submit the Digital Qual Form
    public PageReference saveSubmit(){
        PageReference pgRef;

        saveRecords();

        if(!isError) {
            pgRef = submitDigitalQualForm();
        }

        return pgRef;
    }
    
    //This method is used to check all mendatory question in AE Section and update product detail status value
    private void AccountExecutiveSection(){
        
        for(String sectionName : qualMap.keySet()){
                    
            if(sectionName == 'Account Executive - Opportunity Details' ){
                system.debug('====AccountSection');
                System.debug('loggedInProfileName--->'+loggedInProfileName);

                for(QualWrapper qualWrapper : qualMap.get(sectionName)){

                    if(qualWrapper.isVisible && 
                    String.isBlank(qualWrapper.answer) && 
                    cssClassForAeSectionAccess == 'enabled'
                    ){ //GTMCLS-2639

                        system.debug('====AccountInner');
                        errorMessage =  'Please complete all the questions in the Account Executive - Opportunity Details section.';
                        isError = true;
                        isReadOnly = false;
                        break;

                    }
                }

                if(!isError && 
                !loggedInProfileName.equals('Business Development Manager') && 
                !loggedInProfileName.equals('Solutions Consultant') && 
                Product.Status__c.equals('Ready for AE')){
                Product.Status__c = 'Ready for Assignment';
                }    
                        
                isReadOnly = true; 
                cssClassForAeBdmPsSecAccess = 'disabled';
                cssClassForProdReviewSection = 'disabled';
                cssClassForclariCommentSecAccess = 'disabled'; //GTMSER-2703                 
            }
        }
    }
        //Start GTMCLS-2639 *Ensures all the questions are answered in each section*
        private void BDMSection(){
        
            for(String sectionName : qualMap.keySet()){
                // GTMSER-7197 changed Services Executive - Services Assessment from BDM - Services Assessment
                if(sectionName == 'Services Executive - Services Assessment'){
                
                    for(QualWrapper qualWrapper : qualMap.get(sectionName)){
                        
                        if((qualWrapper.isVisible && 
                            (String.isBlank(qualWrapper.answer) || 
                            qualForm.BDM_Fit__c == null || 
                            qualForm.BDM_Recommended_Fit__c == null)) && 
                            cssClassForBdmSectionAccess == 'enabled') {
                            
                            errorMessage = 'Please complete all the questions in the Services Executive - Services Assessment section.';
                            isError = true;
                            isReadOnly = false;
                            break;
    
                        }
                    }
                }
            }
        }
    
        private void PreSalesSection(){
            
            for(String sectionName : qualMap.keySet()){
                        
                if(sectionName == 'PreSales - Product Assessment'){
                   
                    for(QualWrapper qualWrapper : qualMap.get(sectionName)){
    
                        if((qualWrapper.isVisible && 
                            (String.isBlank(qualWrapper.answer)|| 
                            qualForm.PreSales_Customer_Fit__c == null || 
                            qualForm.PreSales_Recommended_Fit__c == null)) && 
                            cssClassForPsSectionAccess == 'enabled') {
    
                            errorMessage =  'Please complete all the questions in the PreSales - Product Assessment section.';
                            isError = true;
                            isReadOnly = false;
                            break;
    
                        }
                    }
                }
            }
        }
        // End GTMCLS-2639
    //GTMCLS-211 Start Here
    private void BdmPresalesSection2(){
        
        for(String sectionName : qualMap.keySet()){
        // GTMSER-7197 changed Services Executive - Services Assessment from BDM - Services Assessment
            if(sectionName == 'PreSales - Product Assessment' || sectionName == 'Services Executive - Services Assessment'){
            
                for(QualWrapper qualWrapper : qualMap.get(sectionName)){
                    
                    if((qualWrapper.isVisible && String.isBlank(qualWrapper.answer)) || qualForm.BDM_Recommended_Fit__c == null || qualForm.PreSales_Recommended_Fit__c == null || qualForm.PreSales_Customer_Fit__c == null || qualForm.BDM_Fit__c == null) {
                        
                        errorMessage = 'In order for the Qual form to be Submitted, all the sections must be completed (AE, PreSales, BDM). Please use the “Save” button to save your changes.';
                        isError = true;
                        isReadOnly = false;
                        break;
                    
                    }
                }

                             
            }
        }
    }  
    //GTMCLS-211 End Here  
    
    //This method is used to check all mendatory question in BDM and PreSales Section along with BDM/PreSales Fit values
 /* Duplicate method commented as part of GTMCLS-2639
  private void BdmPresalesSection(){
        
        for(String sectionName : qualMap.keySet()){
        
            if(sectionName == 'PreSales - Product Assessment' || sectionName == 'Services Executive - Services Assessment'){
            
                for(QualWrapper qualWrapper : qualMap.get(sectionName)){
                    
                    if((qualWrapper.isVisible && String.isBlank(qualWrapper.answer))
                        || qualForm.PreSales_Customer_Fit__c == null 
                        || qualForm.BDM_Fit__c == null) {
                        
                        errorMessage = 'In order for the Qual form to be Submitted, all the sections must be completed (AE, PreSales, BDM). Please use the “Save” button to save your changes.';
                        isError = true;
                        isReadOnly = false;
                        break;
                    
                    }
                }

                isReadOnly = true; 
                cssClassForAeBdmPsSecAccess = 'disabled';
                cssClassForProdReviewSection = 'disabled'; 
                cssClassForclariCommentSecAccess = 'disabled'; //GTMSER-2703                
            }
        }
    }    
    */
    
    //This method is used to submit the Digital Qual Form and Update Product_Detail__c
    public PageReference submitDigitalQualForm(){
        system.debug('In submitDigitalQualForm');

        spForSubmitOperation = Database.setSavepoint();
        PageReference pageRef;
        isError = false;
        
        System.debug('isValidPermissionSetAssigned----->'+isValidPermissionSetAssigned);
        System.debug('loggedInProfileName----->'+loggedInProfileName);
        
        //GTMCLS-211 Start Here
        If(Product.Status__c.equals('Ready for Assignment')){
            BdmPresalesSection2();
            BDMSection();
            PreSalesSection();
        }
        //GTMCLS-211 End Here 
        
        //GTMCLS-2639 Adding validation for BDM, PreSales sections
        if(loggedInProfileName == 'Account Executive' || 
            loggedInProfileName.equals('Solutions Consultant')  || 
            loggedInProfileName.equals('Business Development Manager') || 
            loggedInProfileName.equals('Regional Sales Director') || 
            loggedInProfileName.equals('Regional Vice President') || 
            loggedInProfileName.equals('Corporate Sales Development') || 
            loggedInProfileName.equals('Customer Success Manager') || 
            loggedInProfileName.equals(Label.CSM_Renewal_Profile) || 
            loggedInProfileName.equals('Sales/Ops') || 
            loggedInProfileName.equals('Sales/Ops Admin') || 
            loggedInProfileName.equals('Renewals') || 
            loggedInProfileName.equals('Workday Integration') ){//GTMCLS-855 //GTMSEC-245 Adding CSM+Renewals Profile Check
            AccountExecutiveSection();
            BDMSection(); 
            PreSalesSection();

        }else if(loggedInProfileName.equals('Business Development Manager') || 
            loggedInProfileName.equals('Solutions Consultant') ){               
                AccountExecutiveSection();
                BdmPresalesSection2();
                BDMSection();
                PreSalesSection();
                
        }else if(loggedInProfileName.equals('Sales/Ops Admin')  || 
            loggedInProfileName.equals('Services Ops')  || 
            loggedInProfileName.equals('Services Ops Admin') ||
            loggedInProfileName.equals('Renewals') || 
            loggedInProfileName.equals('System Administrator')  || 
            loggedInProfileName.equals('Data Administrator')){
                
            system.debug('Hello This is Sys Admin');

            if(Product.Status__c == 'Ready for AE') {
                system.debug('Hello This is Sys Admin');
                AccountExecutiveSection();

            } else if (Product.Status__c == 'In Progress - PreSales/BDM'){            
                AccountExecutiveSection();
                BdmPresalesSection2();
                BDMSection();
                PreSalesSection();                

            }else if(!(loggedInProfileName.equals('System Administrator')  || loggedInProfileName.equals('Data Administrator'))){
               errorMessage = 'You cannot Submit the Form in this status.'; 
               isError = true;
            }
                     
        }else if(isValidPermissionSetAssigned){
            AccountExecutiveSection();
            BdmPresalesSection2();
            BDMSection();
            PreSalesSection();
            
        }else{
            errorMessage = 'You do not have the permission to Submit the Form';
            isError = true;
        }

        if(!isError){
            //GTMSER-1227: AC3: The history of who and when the "Submit" and "Save & Submit" button is captured in Salesforce.
            product.Submitted_By__c = UserInfo.getUserId();
            product.SC_indicates_customer_fit__c = qualForm.PreSales_Customer_Fit__c;
            product.Services_Customer_Fit__c = qualForm.BDM_Fit__c;
            
            //GTMCSL-211 Start Here
             
             product.Recommended_PreSales_Fit__c = qualForm.PreSales_Recommended_Fit__c;
             product.Recommended_BDM_Fit__c = qualForm.BDM_Recommended_Fit__c;
             
             //GTMCSL-211 End Here
             
            //GTMSER-2703, 2906, 2916: Save answer in specified fields of PQ Object, if any
            for(List<QualWrapper> qualWrapperList : qualMap.values()){
                
                for(QualWrapper qualWrapper : qualWrapperList)  {
                    setAnsToSyncToPQ(qualWrapper);
                }
            }
            
            updateProduct();                        
        }

        if(isError){
            isReadOnly = false;
            editPage();

        }else{           
           pageRef = new PageReference('/' + product.Id);
        }

        return pageRef;        
    }

    // Populate values for PQ to sync from Qual Form
    private void setAnsToSyncToPQ(QualWrapper qualWrapper) {

        if((qualWrapper.isVisible && !String.isBlank(qualWrapper.pqObjFieldToSyncAns))
            && (qualWrapper.pqObjFieldToSyncAnsWhen.equals('Saved')|| 
            qualWrapper.pqObjFieldToSyncAnsWhen.equals('Submitted'))) {
            
            if(qualWrapper.pqObjFieldToSyncAns.equals('Status__c')) {
                
                //When Saved operation invoked
                if(qualWrapper.pqObjFieldToSyncAnsWhen.equals('Saved')) {

                    // Don't save --None-- value and also ensure this is editable on form
                    if(!String.isBlank(qualWrapper.answer) && cssClassForProdReviewSection.equals('enabled')) {
                        product.put(qualWrapper.pqObjFieldToSyncAns, qualWrapper.answer);
                    }

                //When Submit or Save & Submit operation invoked
                } else if(qualWrapper.pqObjFieldToSyncAnsWhen.equals('Submitted')) {
                    
                    // Don't save --None-- value
                    if(!String.isBlank(qualWrapper.answer)) {
                        product.put(qualWrapper.pqObjFieldToSyncAns, qualWrapper.answer);
                    }
                }

            } else {
                product.put(qualWrapper.pqObjFieldToSyncAns, qualWrapper.answer);
            }
        }
    }

    @TestVisible private void updateProduct() {

        try{
            update product;

        } catch (DmlException e) {
            errorMessage = e.getDmlMessage(0);
            isError = true;

        } catch (Exception e) {
            errorMessage = e.getMessage();
            isError = true;            
        }        

        if(isError) {
            isReadOnly = false;

            if(spForSaveOperation != null) {
                Database.rollback(spForSaveOperation);
            } else if(spForSubmitOperation != null) {
                Database.rollback(spForSubmitOperation);
            }
        }        
    }

    //This method is used to provide fit values access to Manager.
   @TestVisible private void loadFitValues(){

        bdmFitOptionsList = new List<SelectOption>();
        preSalesFitOptionsList = new List<SelectOption>();
        Schema.DescribeFieldResult bdmfieldResult = Product_Detail__c.Services_Customer_Fit__c.getDescribe();
        List<Schema.PicklistEntry> bdmFitOptions = bdmfieldResult.getPicklistValues();
        Schema.DescribeFieldResult preSalesfieldResult = Product_Detail__c.SC_indicates_customer_fit__c.getDescribe();
        List<Schema.PicklistEntry> preSalesFitOptions = preSalesfieldResult.getPicklistValues();
        
        //BDM Fit - Picklist options 
        bdmFitOptionsList.add(new SelectOption('','--None--'));
        for( Schema.PicklistEntry bdmPickListVal : bdmFitOptions){

            bdmFitOptionsList.add(new SelectOption(bdmPickListVal.getLabel(),bdmPickListVal.getValue()));

        } 
        //PreSales Customer Fit - Picklist options
        preSalesFitOptionsList.add(new SelectOption('','--None--'));
        
        for( Schema.PicklistEntry preSalesPickListVal : preSalesFitOptions){
            preSalesFitOptionsList.add(new SelectOption(preSalesPickListVal.getLabel(),preSalesPickListVal.getValue()));
        }

        preSalesFitSelected = qualForm.PreSales_Customer_Fit__c;
        bdmFitSelected = qualForm.BDM_Fit__c;
    }

    /* Author: Bhoopender Pal Singh 
    * GTMSER-1965 - AC#4 - Check Edit/Read permissions
    * Date: Sep 16, 2019
    */
    private void loadQualFormPermissions() {
        isAccessible = NOL_QualPermissionUtils.checkQualFormAccessible(NOL_QualPermissionUtils.QualFormAccess.IS_ACCESSIBLE);
        isUpdateable = NOL_QualPermissionUtils.checkQualFormAccessible(NOL_QualPermissionUtils.QualFormAccess.IS_UPDATEABLE);
        system.debug('=================isAccessible: ' + isAccessible);
        system.debug('=================isUpdateable: ' + isUpdateable);
    }    
    
    /* Author: Bhoopender Pal Singh
    * GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    * Date: Sep 26, 2019
    */
    private void loadFitPermissions() {
        List<NOL_QualPermissionUtils.FitTypes> fitTypeList = NOL_QualPermissionUtils.getEditableFits(product.Status__c);

        if(fitTypeList.contains(NOL_QualPermissionUtils.FitTypes.SOLUTIONS_CONSULTANT)) {
            presalesFitReadOnlyClass = 'enabled';        
        }

        if(fitTypeList.contains(NOL_QualPermissionUtils.FitTypes.BDM)) {
            bdmFitReadOnlyClass = 'enabled';
        }

        system.debug('=================presalesFitReadOnlyClass: ' + presalesFitReadOnlyClass);
        system.debug('=================bdmFitReadOnlyClass: ' + bdmFitReadOnlyClass);
    }  

    public void whenQuestionAnswered() {
        system.debug('=================whenQuestionAnswered() started: answeredQSection, answeredQId = ' + answeredQSection + ', ' + answeredQId);
        
        //Get the concerned question and set the answer manually here in case list (in other cases this is set automatically through SFDC property binding) 
        QualWrapper curreQualWrapper;

        for(QualWrapper qualWrapper : qualMap.get(answeredQSection)) {   

            if(qualWrapper.questionId == answeredQId) {

                if(qualWrapper.questionType.equals('Multi-Select')) {
                    qualWrapper.answer = String.join(qualWrapper.answerList, ';');
                    system.debug('================qualWrapper.answer = qualWrapper.answerList: ' + qualWrapper.answer + ' = ' + qualWrapper.answerList);
         
                }

                curreQualWrapper = qualWrapper;
                break;
            }
        }

        //
        List<Id> subQIdMatchedCriteriaList;

        //Check each collected criteria for the concerened Question and identify the matched criteria
        for(NOL_Qual_Question_Response__c criteria : qIdToCriteriaListMap.get(answeredQId)) {
            
            try{
                //Check if criteria matched
                Boolean isCriteriaMatched;

                if(curreQualWrapper.questionType.equals('Multi-Select')) {
                    isCriteriaMatched = NOL_QualUtils.evalOpeartorExpression(curreQualWrapper.answer, criteria.Answer__c, criteria.Operator__c, true, NOL_QualUtils.LIST_VALUES_SEPARATOR);
                } else {
                    isCriteriaMatched = NOL_QualUtils.evalOpeartorExpression(curreQualWrapper.answer, criteria.Answer__c, criteria.Operator__c);
                }

                //If match found
                if(isCriteriaMatched) {

                    // Collect sub questions against this matched criteria
                    subQIdMatchedCriteriaList = qCriteriaIdToSubQIdListMap.get(criteria.Id);
                    break;
                }
            } catch(NOL_QualUtils.InvalidArgumentsException e) {
                break;
            }               
        }

        system.debug('=================subQIdMatchedCriteriaList: ' + subQIdMatchedCriteriaList);

        //Show/Hide the SubQuestions
        for(QualWrapper qualWrapper : qualMap.get(answeredQSection)) {
            system.debug('=================qualWrapper.questionId=' + qualWrapper.questionId);

            //Show the sub questions specified against matched criteria, if any
            if(subQIdMatchedCriteriaList !=null && subQIdMatchedCriteriaList.contains(qualWrapper.questionId)) {
                qualWrapper.isVisible = true;
                system.debug('=================qualWrapper.questionId=visibility: ' + qualWrapper.questionId + '=true');
            
            //Hide the sub questions, if any previously shown, against for then matched criteria
            } else if(qIdToSubQIdMatchedCriteriaListMap.get(answeredQId) != null
                        && qIdToSubQIdMatchedCriteriaListMap.get(answeredQId).contains(qualWrapper.questionId)) {

                qualWrapper.isVisible = false;
                system.debug('=================qualWrapper.questionId=visibility: ' + qualWrapper.questionId + '=false');
            }
        }

        qIdToSubQIdMatchedCriteriaListMap.put(answeredQId, subQIdMatchedCriteriaList);

        system.debug('=================whenQuestionAnswered() finished');
    }

    public class QualWrapper{
        public String questionTitle{get;set;}
        public String questionType{get;set;}
        public Id questionId{get;set;}
        public String helpText{get;set;} //Get Help Text from NOL qual form
        public String answer{get;set;}
        public List<String> answerList{get;set;}
        public List<SelectOption> optionsList{get;set;}
        public String section{get;set;}
        public String pqObjFieldToSyncAns{get;set;}
        public String pqObjFieldToSyncAnsWhen{get;set;}
        public Boolean isParent{get;set;} //Question has child nodes?
        public Boolean isVisible{get;set;}
        public Boolean isFaqLinkAvail{get;set;}
        public Boolean isSkuAvailabilityMatrixAvailable{get;set;}  //GTMCLS -2336 (Requirement -2)
    }
    
    //GTMCLS-2823 starts
    public static string getOverallProdQualificationStatus(string status1, string status2) {
        string status = '';
        List<Product_Qualification_Status_Mapping__c> prodStatusMapping = Product_Qualification_Status_Mapping__c.getAll().values();
        
        for(Product_Qualification_Status_Mapping__c pqsm : prodStatusMapping) {
            if(pqsm.Approval_Status_1__c != null && pqsm.Approval_Status_1__c != '' && 
               pqsm.Approval_Status_2__c != null && pqsm.Approval_Status_2__c != '' &&
               pqsm.Overall_Qualification_Status__c != null && pqsm.Overall_Qualification_Status__c != '') {
                if(status1 != null && status1 != '' && status2 != null && status2 != '') {
                    if(pqsm.Approval_Status_1__c.equalsignorecase(status1) && pqsm.Approval_Status_2__c.equalsignorecase(status2)) {
                        status = pqsm.Overall_Qualification_Status__c;
                    }
                }
            }
        }
        return status;
    }
    //GTMCLS-2823 ends

    //GTMSER-2687: NOL - Qual Form UI Enhancements (i. e.Convert lists in "Account Details" to tables)
    public class ProductFunctionWrapper {
        public String productArea{get;set;}
        public String productFunction{get;set;}
        public String targetDate{get;set;}
        public String actualDate{get;set;}
    }
}