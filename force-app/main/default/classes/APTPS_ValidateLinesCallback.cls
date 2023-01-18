/*************************************************************************************************************
  * e neiman template callback 2/13/2015
  *
  *  DefaultValidationCallback   "Apex Class"
  <EOF>
  Name    DefaultValidationCallback   
  Namespace Prefix    Apttus_Config2  
  Installed Package   Apttus Configuration & Pricing
  <EOF>
  global class DefaultValidationCallback
  Available in Versions: 6.705 - Current
  Interfaces (2)
  Name
  IValidationCallback2
  IValidationCallback
  Constructors (1)
  Signature
  DefaultValidationCallback()
  Methods (3)
  Signature
  Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, LIST assetItems)
  Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart)
  Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, LIST rampLineItems)
  <EOF>
  History
1.Prachi Dandriyal - GTMSM-1582 - Ability to deselect a product features from within a bundle   
2.Mounika Challa - 06/29/2020 - GTMOM 2682 - Renewal UI/UX Changes
3.Anil Kumar Anubrolu - 06/31/2020 - GTMOM-2778 - Surpassing Adjustment Type Option = Discount % or Price Override to Scout Renewal quotes
4.VipinKommid - 09/15/2020 - GTMCLS 310 - Accounting Center Packaging & Pricing 
5.Anil Kumar Anubrolu - 10/11/2020 - GTMSM-2336 - Bundle Quantity validation for Expansion quotes
6.Anil Kumar Anubrolu - 10/11/2020 - GTMSM-2337 - Need to restrict user from selecting the additional sourcing sku
7.Anil Kumar Anubrolu - 10/12/2020 - GTMSM-2259 - Need to restrict user from selecting sourcing sku's at the time of renewal
8.VipinKommidi          12/10/2020   GTMCLS – 1081 : WSP Product Setup & Packaging.
9. Dheeraj              01/25/2021  GTMCLS - 1313/1737 : Procurement or Essentials required for Contract and Supplier Mananagement if selected in CART
10.Jana  Gowkanpalli    02/08/2021   GTMCLS-1753 : To check HCM OR CORE FIN products are avilable in cart or Assert when the WSP added firstitme in Add On Quote.
11.Jana  Gowkanpalli    02/24/2021   GTMCLS-1349 : Is Account WSP Enabled or not.
12.Jana  Gowkanpalli    03/22/2021   GTMCLS-2037 : Include Term Validation for HCM/FINS Asset.
13.Sunit Maddali        03/22/2021   GTMCLS-1990 : Essentials in Cart or Asset
14.Jana Gowkanaplli     04/20/2021   GTMCLS-2059 -- FSE Planning SKU validations for net new transcation for Instance Additional SKU.
15.vsabbella    05262021   GTMCLS-2340 -- Display error for addon subscription along with expansion.
16.Jana Gowkanpalli     05/27/2021    GTMCLS-2359-- Updated validation for Sales Planning Product.(PLNS,PLNSI)
17.Sunit Maddali        05/26/2021 -  GTMCLS-2266 - Net-new & Add On quote Increase and Decrease in GB
18. Rohan Chinchwade    06/24/2021 -  GTLCLS-2159 - adding exception for special legacy adaptive add-on Transaction
19. Dheeraj              06/22/2021 -  GTMCLS-2386 - Manual update of GB value across all ramp lines for XTND SKU
20. Sunit Maddali        06/17/2021 -  GTMCLS-2439 - Decrease (Downgrade) in GB for POWER Users Only
21. Prachi Dandriyal     08/25/2021 - GTMCLS-2923  - Bypass Instance Sku for Exception Handling 
22. Rajesh Kumar         08/15/2021 - GTMCLS 2717 - Product Tier Dependency & Exception Handling Rule
23. Rajesh Kumar         09/15/2021 - GTMCLS-2889 - Expansions - Downgrade (Existing Tier > New Tier) for Annual and Non-CoTermed
24. Jana Gowkanapalli.   09/20/2021   GTMCLS-2988 -To Show error message Ramplines Quantity if lessthan Primary line Quantity for Adaptive SKU's
25. Rohan Chinchwade   10/07/2021 - GTMCLS-3120 - Adaptive Skus add on scenario fix 
26. Rohan Chinchwade     09/15/2021 - GTMCLS-2796 - Added new LDP additional skus
27. Rohan Chinchwade     10/21/2021  - GTMCLS-3142 - Additional Sku's No Pre-requisite changes 
28. Rohan Chinchwade    11/17/2021 - GTMCLS-3298 - Bundle User addional add on scenario
29. Pankaj Verma         10/07/2021  - GTMCLS-2633 : Bypass WSP Validation - while already WSP customer
30. Parvathi Chunduri   10/09/2021 - GTMCLS-2918 : WSP- Bypass Capability to Exclude WSP on Add-on Quotes
31. Ramadhar Mishra     2/1/2022     GTMCLS-3512 LRNXE - Expansion- Annual & Growth Event, No Downgrades allowed
32. Ramadhar Mishra     2/9/2022     GTMCLS-3824 Defect Fix Not able to see Downgrade error message for Addon Growth
33. Ramadhar Mishra     03/10/2022    GTMCLS-3585 - Msging - Configuration Rules - Ramp Quantity
34. Monisha Divakaran    03/01/2022    GTMCLS-3808- Strategic Sourcing User (Additional) SKU Should Default Future Qty to Y1 Qty
35. vsabbella            02/11/2022   GTMCLS-3833 Platform Stabilization 
36. Anil Upreti          04/21/2022   GTMCLS-3625  Msging - Quantity Logic (Expansions->Annual) 
37. Anil Upreti          04/25/2022    GTMCLS-4022  Msging - Expansion- Annual & Growth Event, No Downgrades allowed
38. Md Aftab            05/19/2022    GTMCLS-4407  WGC Enhancement: WGC Customer SKU Controls - Renewal & Renewal AddOn
39. Imran Ahmad         05/19/2022    GTMCLS-4409  WGC Enhancement: WGC Customer SKU Controls - Exception Handling (Net New/Add On)
40. Nikita Talreja      06/08/2022    GTMCLS-4406 WGC Enhancement: WGC Customer SKU Controls
41. Prachi Dandriyal    07/01/2022    GTMCLS-4574 Removing SRC and LDPSRC from String to exclude the Quantity Checks for all transaction
42. Dheeraj Perumalla   05/19/2022    GTMCLS-4456  Prism 5.7 Ability to manually enter/update 'Quantity' for PRA-03/LDPPRA-03 (Quantity and Ramp logic)
43. Gaurav Kumar        05/19/2022    GTMCLS-4156  Prism 5.6 Ability to manually enter/update 'Quantity' for all PRACU skus (Quantity and Ramp logic)
44. Gaurav Kumar        06/02/2022    GTMCLS-4630 Bypass validation and update ramp lines based on primary line qty if qty = 0 or 1 for PRACU/LDPPRACU, PRACU-02/LDPPRACU-02
45. Gaurav Kumar        06/08/2022    GTMCLS-4631 Bypass validation and update ramp lines based on primary line qty if qty>=10 for PRA-03/LDPPRA-03
46. Deepika Reddy Palwai 08/22/2022     GTMCLS-5157 Expansions - Downgrade for Annual & Growth Events
47. Sunit Maddali        09/08/2022     GTMCLS-5183 BYOK: Enable Growth Event Transactions for increase in FSE mid term
48. Sunit Maddali        09/08/2022     GTMCLS-5243 BYOK: Enable Annual/ True Up expansions for increase in FSE mid term
49. Sagar Gunjal        07/09/2022    GTMCLS-5309  Committed Usage Offers - set up ramp quantity rules.
50. Sagar Gunjal        11/30/2022    GTMCLS-5297  Committed Usage Offers - Growth Event No Downgrades allowed.
51. Somya Srivastava    11/30/2022    GTMCLS-5295  Committed Usage Offers - Quantity for annual true up events must be in increments of 50K.
52. Mounika Challa.      01/04/2023     GTMCLS-5998 Mandatory WSP for subsequent purchases
53. Divanshi Saneja      11/17/2022    GTMCLS-5499 VNDLY Training Kit Additional User Sku's Add-on Setup
54. Divanshi Saneja      12/03/2022    GTMCLS-5500  VNDLY Cart Configuration Rules Quantity Setup (LE and LDP)


****************************************************************************************************************************************/
global with sharing class APTPS_ValidateLinesCallback implements Apttus_Config2.CustomClass.IValidationCallback2 {

    /**
     * Callback to validate the line items in the cart
     * @param cart the cart object to validate
     * @return the validation result
     */
    /******************* Start - GTMSM-1582 **********************************/
    // Constant SCOUT Product Configuration Codes   
    public static final String PRODUCT_CODE = 'SW-SRS-USER-100';
    public static final String BOARD_PRODUCT_CODE = 'SW-SUP-ON-100';
    public static final String PRODUCT_CONFIG_STD = 'Standalone';
    public static final String PROPOSL_RECORD_TYPE = 'Proposal';
    public static final Set<String> bundleprod = new Set<String>{'LDPSRCESS','SRCCNT','SRCSM','LDPSRCINT','LDPSRCCNT','LDPSRCSM','SRCINT','SRCESS','SRCEXP','LDPSRCEXP'}; // GTMSM-2336 //GTMCLS-4574: Removed 'LDPSRC','SRC'
    //GTMCLS - 1313/1737
    public static final String CONTRACT_LE_CODE = 'SRCCNT';
    public static final String CONTRACT_LDP_CODE = 'LDPSRCCNT';
    public static final String SUPPLIER_LE_CODE = 'SRCSM';
    public static final String SUPPLIER_LDP_CODE = 'LDPSRCSM';
    public static final String PRO_LE_CODE = 'PRO';
    public static final String PRO_LDP_CODE = 'LDPPRO';
    public static final String ESSENTIALS_LE_CODE = 'SRCESS';
    public static final String ESSENTIALS_LDP_CODE = 'LDPSRCESS';
	public static Set<String> pracuValidationSKUSet=APTS_PricingEngineUtil.configSettingDataSetMap.get('PracuQuantityValidation');//GTMCLS-4156
    public static Set<String> EWM_STOW_VNDLY_SKUS_CONFIG = APTS_PricingEngineUtil.configSettingDataSetMap.get('EWM_STOW_VNDLY_SKUS_CONFIG');//GTMCLS-5500
    public static Set<String> WPM_VNDLY_SKUS_CONFIG = APTS_PricingEngineUtil.configSettingDataSetMap.get('WPM_VNDLY_SKUS_CONFIG');//GTMCLS-5500

    //GTMCLS - 1313/1737
    /******************* End - GTMSM-1582 **********************************/
    global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {

        // get current runtime context on cart
        map<String,decimal> mapPreviousQuantity = new Map<String,decimal>(); //GTMCLS-4456
        map<String,decimal> mapPreviousPracuQuantity = new Map<String,decimal>(); //GTMCLS-4156 
        Map < String, String > RuntimeContextcartmap = Apttus_Config2.RuntimeContext.getParameters();
        Id configId = cart.getConfigSO().Id;
        Id proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        String currencyIsoCode = cart.getConfigSO().CurrencyIsoCode; // GTMCLS – 1081 
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        Apttus_Proposal__Proposal__c propObj = APTPS_ValidateLinesCallbackSelector.getProposal(proposalId); // GTMSM-2337
        map<String,decimal> mapVndlyEWMSTOWPreviousQuantity = new Map<String,decimal>();//GTMCLS-5500
        map<String,decimal> mapVndlyWPMPreviousQuantity = new Map<String,decimal>();//GTMCLS-5500
        //GTMCLS-3833 - Moving the assets query up here
        List < Id > accountId = new List < Id > ();
        accountId.add(propObj.Apttus_Proposal__Account__c);
        List < String > fieldnames = new List < String > {
            'APTS_Product_Code__c',
            'Apttus_Config2__AssetStatus__c',
            'APTS_SKU_End_Date__c',
            'Usage_Tier__c'
        };
    String wgcbundleattribute = null; //GTMCLS-4407
        List<Apttus_Config2__AssetLineItem__c> assetLines = APTPS_ValidateLinesCallbackService.getAssetLineItems(accountId, fieldnames);
        //GTMCLS-3833 - end
        result.isSuccess = true;
          Map<String, decimal > primaryQuantity=new Map<String, decimal >(); //GTMCLS-2988
        // Start GTLCLS-2159
        //Retrieving exceptional handling values   
        List < String > Excption = new List < String > ();
        if (propObj.APTS_Exception_Handling__c != null) {
            Excption = propObj.APTS_Exception_Handling__c.split(';');
        }
        // END GTLCLS-2159
        Set<String> AllAssetProducts = new Set <String>();  // GTMCLS-3142
        //GTMSM-2337 Start Code ////GTMCLS-1349 start
        Set < String > assetprd = new Set < String > ();
        Set < String > assetprd1 = new Set < String > (); //GTMCLS-1313/1737
        Set < String > assetprdAll = new Set < String > ();
        Map < String, String > assetToTierMap = new Map < String, String > (); //GTMCLS-2717
        
        // GTMCLS-3142 Start
         if (cart.getConfigSO().APTS_Proposal_Record_Type__c == APTPS_Constants.RT_PROP_PROPOSAL) {
            //GTMCLS-3833 - Start
            //List < Id > accountId = new List < Id > ();
            //accountId.add(propObj.Apttus_Proposal__Account__c);
            /*List < String > fieldnames = new List < String > {
                'APTS_Product_Code__c',
                'Apttus_Config2__AssetStatus__c',
                'APTS_SKU_End_Date__c'
            }; 

            for (Apttus_Config2__AssetLineItem__c asst: APTPS_ValidateLinesCallbackService.getAssetLineItems(accountId, fieldnames)) {
                if (asst.Apttus_Config2__AssetStatus__c == APTPS_Constants.STATUS_ACTIVATED) {
                AllAssetProducts.add(asst.APTS_Product_Code__c);
                }
            }
            */

            for (Apttus_Config2__AssetLineItem__c asst: assetLines) {
                if (asst.Apttus_Config2__AssetStatus__c == APTPS_Constants.STATUS_ACTIVATED) {
                AllAssetProducts.add(asst.APTS_Product_Code__c);
           }
            }
            //GTMCLS-3833 End
           }
         // GTMCLS-3142 End 


        /****************************************** GTMCLS-2717 Starts*************************/
        if (propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE 
                || propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_RENEWAL
                 || 'Expansion (Addtl EEs)'.equalsIgnoreCase(propObj.Apttus_Proposal__Opportunity__r.type)) {
                        //GTMCLS-2889
            //GTMCLS-3833  -Start
            //List < Id > accountIdList = new List < Id > ();
            //accountIdList.add(propObj.Apttus_Proposal__Account__c);

            /*List < String > fieldnamesList = new List < String > {
                'APTS_Product_Code__c',
                'Apttus_Config2__AssetStatus__c',
                'APTS_SKU_End_Date__c',
                'Usage_Tier__c'
            };

            for (Apttus_Config2__AssetLineItem__c asstl: APTPS_ValidateLinesCallbackService.getAssetLineItems(accountIdList, fieldnamesList)) {

                assetprdAll.add(asstl.APTS_Product_Code__c);
                assetToTierMap.put(asstl.APTS_Product_Code__c, asstl.Usage_Tier__c);
            }

            */
            for (Apttus_Config2__AssetLineItem__c asstl: assetLines) {

                assetprdAll.add(asstl.APTS_Product_Code__c);
                assetToTierMap.put(asstl.APTS_Product_Code__c, asstl.Usage_Tier__c);
        }
            //GTMCLS-3833  -end

        }
        /****************************************** GTMCLS-2717 Ends *************************/

        //GTMCLS-1753 -- Start
        if (propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE || propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPTY_TYPE_EXPN ) { // GTMCLS-5998 Added Expansion Condition

            //List < Id > accountIdList = new List < Id > ();
            //accountIdList.add(propObj.Apttus_Proposal__Account__c);



            for (Apttus_Config2__AssetLineItem__c asstl: assetLines) {
                //  GTMCLS-3833  -end
                if (propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE) { // // GTMCLS-5998- Added If Condition
                assetprd.add(asstl.APTS_Product_Code__c);
                }
                //GTMCLS-1313/1737
                if (propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE) {
                    assetprd1.add(asstl.APTS_Product_Code__c);
                }

                if (asstl.Apttus_Config2__AssetStatus__c == APTPS_Constants.STATUS_ACTIVATED && asstl.APTS_SKU_End_Date__c >= propObj.Apttus_Proposal__ExpectedStartDate__c && ((propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE && propObj.Apttus_Proposal__Opportunity__r.Sub_Type__c != APTPS_Constants.GROWTH_EVENT) && (!(Excption.contains('Bypass WSP Inclusion Rule')))) ||(((propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE && propObj.Apttus_Proposal__Opportunity__r.Sub_Type__c == APTPS_Constants.GROWTH_EVENT )||(propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPTY_TYPE_EXPN)) && !(Excption.contains('Bypass WSP Inclusion Rule')) && (propObj.Apttus_Proposal__Account__r.APTS_Success_Plan_Tier__c == 'WSP - Accelerate Plus' || propObj.Apttus_Proposal__Account__r.APTS_Success_Plan_Tier__c == 'WSP - Accelerate'))) { // // GTMCLS-5998 - Added Conditions for wsp new tiers //GTMCLS-2037 //GTMCLS-2633//GTMCLS-2918
                    APTS_WspProductPackagingService.wspPlatformProductMap = APTS_WspProductPackagingService.getWspPlatformProducts(
                        asstl.APTS_Product_Code__c,
                        APTS_WspProductPackagingService.wspPlatformProductMap
                    );
                }

                //GTMCLS-1313/1737
            }
        }
        //GTMSM-2337 End Code //GTMCLS-1349 end  //GTMCLS-1753 -- end

        //Ruslan Vekua 8.8.2018' - GTMENT-246 - Execute for the legacy quotes only
        if (cart.getConfigSO().APTS_Proposal_Record_Type__c != APTPS_Constants.RT_PROP_PROPOSAL) {

            System.debug('!!..after pricing APTS_CustomPricingCallback_@_Workday');
            Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            //ID configId = cart.getConfigSO().Id;
            //ID proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
            result.isSuccess = true;
            //this section retrieves the user profile
            ID profileID = UserInfo.getProfileId();
            Profile profile = [Select Name FROM Profile where Id =: profileID];
            System.debug('!!....profile.Name ' + profile.Name);
            //   Apttus_CPQApi.CPQ.ComputeNetPriceResponseDO priceResponse = Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);
            if (profile.name != 'Customer Service Operation with Services Deal Desk' && profile.name != 'Sales/Ops Admin') {
                //This section retrieves opportunity fields needed to validate the "not all products" condition
                // Apttus_Proposal__Proposal__c propObj = [SELECT Apttus_Proposal__Opportunity__r.type, Apttus_Proposal__Opportunity__r.recordTypeID FROM Apttus_Proposal__Proposal__c WHERE ID = :proposalId]; // GTMSM-2337
                system.debug('!!..type ' + propObj.Apttus_Proposal__Opportunity__r.type);
                //GTMCLS-3833 - Start
                Schema.DescribeSObjectResult propSobjDescResult = Opportunity.SObjectType.getDescribe();
                Map<Id,Schema.RecordTypeInfo> oppotyRTMap = propSobjDescResult.getRecordTypeInfosById();
                ID recordTypeID = propObj.Apttus_Proposal__Opportunity__r.recordTypeID;
                //RecordType recT = [Select ID, Name From RecordType Where id =: recordTypeID];
                String recTName = oppotyRTMap.get(recordTypeID).getName();
                //GTMCLS-3833 - End
                system.debug('!!..RecordType ' + recTName);
                if ((propObj.Apttus_Proposal__Opportunity__r.type == 'Premium Success Package' || propObj.Apttus_Proposal__Opportunity__r.type == 'Education (ODE/MSS/ESS)') && (recTName == 'Services Opportunity' || recTName == 'Subscription Opportunity')) {



                    //this section reads through the summaries looking for an adjustment 
                    List < Apttus_Config2__SummaryGroup__c > summaries = [SELECT
                        Name, Apttus_Config2__AdjustmentType__c, Apttus_Config2__AdjustmentAmount__c
                    FROM Apttus_Config2__SummaryGroup__c WHERE Apttus_Config2__ConfigurationId__c = :configId];

                    for (Integer i = 0; i < summaries.size(); i++) {
                        system.debug('!!..' + summaries.get(i).name + ' ' + summaries.get(i).Apttus_Config2__AdjustmentType__c + ' ' + summaries.get(i).Apttus_Config2__AdjustmentAmount__c);
                        if (summaries.get(i).Apttus_Config2__AdjustmentType__c != null && summaries.get(i).Apttus_Config2__AdjustmentAmount__c > 0) {
                            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please contact deal desk for discounting'));
                            result.isSuccess = false;
                            return result;
                        }
                    }
                }
            }
        }
        //GTMOM 2682 - Start Here
        if (cart.getConfigSO().APTS_Proposal_Record_Type__c == PROPOSL_RECORD_TYPE) {

            //Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
            //ID configId = cart.getConfigSO().Id;
            //ID proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
            result.isSuccess = true;
            //GTMOM-2778 APTS_Quote_Identifier__c added
            //  Apttus_Proposal__Proposal__c propObj = [SELECT Apttus_Proposal__Opportunity__r.type,APTS_Quote_Identifier__c, Apttus_Proposal__Opportunity__r.recordTypeID FROM Apttus_Proposal__Proposal__c WHERE ID = :proposalId]; // GTMSM-2337
            /* List < Apttus_Config2__SummaryGroup__c > summaries = [SELECT
             Name, Apttus_Config2__AdjustmentType__c, Apttus_Config2__AdjustmentAmount__c
             FROM Apttus_Config2__SummaryGroup__c WHERE Apttus_Config2__ConfigurationId__c = :configId];
             //GTMOM-2778 propObj.APTS_Quote_Identifier__c added
             if (propObj.Apttus_Proposal__Opportunity__r.type == 'Renewal' && !(propObj.APTS_Quote_Identifier__c)) {
                 //this section reads through the summaries looking for an adjustment 
                 for (Integer i = 0; i < summaries.size(); i++) {
                     if (summaries.get(i).Apttus_Config2__AdjustmentType__c == '% Discount' || summaries.get(i).Apttus_Config2__AdjustmentType__c == 'Discount Amount' || summaries.get(i).Apttus_Config2__AdjustmentType__c == 'Price Override') {
                         result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The discounting application "adjustment type" you have selected is not applicable to this cart, please select: Add-On Discount % or Add-On Target TCV and re-price.'));
                         result.isSuccess = false;
                         return result;
                     }
                 }
             }
             //GTMOM-2778 APTS_Quote_Identifier__c added
             if ((propObj.Apttus_Proposal__Opportunity__r.type == 'Net New' || propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription' || propObj.Apttus_Proposal__Opportunity__r.type == 'Expansion (Addtl EEs)') && !(propObj.APTS_Quote_Identifier__c)) {
                 //this section reads through the summaries looking for an adjustment 
                 for (Integer i = 0; i < summaries.size(); i++) {
                     if (summaries.get(i).Apttus_Config2__AdjustmentType__c == 'Add On % Discount' || summaries.get(i).Apttus_Config2__AdjustmentType__c == 'Add On Target TCV') {
                         result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The discounting application "adjustment type" you have selected is not applicable to this cart, please select: Discount %, Discount Amount, or Price Override and re-price.'));
                         result.isSuccess = false;
                         return result;
                     }
                 }
             }*/ //Commented by Venkatesh
       

             //Start GTMCLS-2266*/
            
            list < Apttus_Config2.LineItem > allLines = cart.getLineItems();
            list < Apttus_Config2__LineItem__c > lineItems = new list < Apttus_Config2__LineItem__c > ();
            for (Apttus_Config2.LineItem lineItemMO: allLines) {
                lineItems.add(lineItemMO.getLineItemSO());
            }
            Decimal xtndQuantity;  //GTMCLS - 2386
            Decimal messagingQuantity; //GTMCLS-3585 
            Decimal committedUsageQuantity; //GTMCLS-5309
            for(Apttus_Config2__LineItem__c li : lineItems )
            {  
                 //GTMCLS - 4456 Start
                if(propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE ||
                    propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPTY_TYPE_EXPN ||
                    propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_RENEWAL ||
                    propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_NET_NEW){
                       if(li.APTS_PeriodNumber__c !=NULL && li.Is_Ramped__c && (li.Product_Code__c == APTPS_Constants.PRA03 ||
                       li.Product_Code__c == APTPS_Constants.LDPPRA03)){
                            mapPreviousQuantity.put(String.valueOf(li.APTS_PeriodNumber__c) + li.Apttus_Config2__OptionId__r.Name
                            ,li.Apttus_Config2__Quantity__c);
                        }

                        //GTMCLS-5500 START                                                     }
                        if(li.APTS_PeriodNumber__c !=NULL && li.Is_Ramped__c && EWM_STOW_VNDLY_SKUS_CONFIG!=NULL && EWM_STOW_VNDLY_SKUS_CONFIG.contains(li.Product_Code__c)){
                            mapVndlyEWMSTOWPreviousQuantity.put(String.valueOf(li.APTS_PeriodNumber__c) + li.Apttus_Config2__OptionId__r.Name
                                                    ,li.Apttus_Config2__Quantity__c);
                        } 
                        if(li.APTS_PeriodNumber__c !=NULL && li.Is_Ramped__c && WPM_VNDLY_SKUS_CONFIG!=NULL && WPM_VNDLY_SKUS_CONFIG.contains(li.Product_Code__c)){
                            mapVndlyWPMPreviousQuantity.put(String.valueOf(li.APTS_PeriodNumber__c) + li.Apttus_Config2__OptionId__r.Name
                                                    ,li.Apttus_Config2__Quantity__c);
                        } 
                        //system.debug('WPM_VNDLY_SKUS_CONFIG>>'+WPM_VNDLY_SKUS_CONFIG);
                        //system.debug('EWM_STOW_VNDLY_SKUS_CONFIG>>'+EWM_STOW_VNDLY_SKUS_CONFIG);
                        //system.debug('mapVndlyEWMSTOWPreviousQuantity>>'+mapVndlyEWMSTOWPreviousQuantity);
                        //system.debug('mapVndlyWPMPreviousQuantity>>'+mapVndlyWPMPreviousQuantity);

                        //GTMCLS-5500 END
                         
                        // GTMCLS-4156 STARTS
                        if(li.APTS_PeriodNumber__c !=NULL && li.Is_Ramped__c && pracuValidationSKUSet!=NULL && pracuValidationSKUSet.contains(li.Product_Code__c)){
                            mapPreviousPracuQuantity.put(String.valueOf(li.APTS_PeriodNumber__c) + li.Apttus_Config2__OptionId__r.Name
                            ,li.Apttus_Config2__Quantity__c);
                        }
                        // GTMCLS-4156 ENDS
            
                        }
                //GTMCLS - 4456  End 

                if((li.Apttus_Config2__LineStatus__c == 'New' || ( li.Apttus_Config2__LineStatus__c == 'Renewed' && !APTS_PricingCallBackService.isPowerUser)) && li.Product_Code__c == 'XTND' && li.Data_Usage_Limit_GB__c > li.Apttus_Config2__Quantity__c)  //GTMCLS-2439
                {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decreasing the GB value below the defaulted value of '+ li.Data_Usage_Limit_GB__c +' is not allowed for the XTND SKU'));
                    result.isSuccess = false;
                    return result;
                }
                
                  // Start GTMCLS-2988 
                if( 
                    li.Apttus_Config2__IsPrimaryLine__c     
                    &&  
                    li.Apttus_Config2__LineType__c == APTPS_Constants.LINE_OPTION   &&
                    (li.Product_Code__c==APTPS_Constants.ADAPTIVE_BASEPLUS_USER ||li.Product_Code__c==APTPS_Constants.ADAPTIVE_BASE_USER ||li.Product_Code__c==APTPS_Constants.ADAPTIVE_BUNDLE_USER || li.Product_Code__c == APTPS_Constants.STRATEGIC_SRC_USER_ADD_LE || li.Product_Code__c == APTPS_Constants.STRATEGIC_SRC_USER_ADD_LDP) //GTMCLS-3808
                ) { 
                    primaryQuantity.put(li.Product_Code__c, li.Apttus_Config2__Quantity__c);   
                }  
                //end  GTMCLS-2988
                //GTMCLS - 2386 Start
                xtndQuantity = li.Product_Code__c  == 'XTND' && xtndQuantity == null? li.Apttus_Config2__Quantity__c : xtndQuantity;
                
                if(li.Product_Code__c  == 'XTND' && xtndQuantity != li.Apttus_Config2__Quantity__c){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity (Data Usage GB) for Extend SKU must be the same across all lines'));
                    result.isSuccess = false;
                    return result;
                }   
                //GTMCLS - 2386 End
         //GTMCLS-3512 -  Start
                if(li.Product_Code__c == 'LRNXE' && 

                   //li.Opportunity_Type__c == 'Expansion (Addtl EEs)' && 
                   li.APTS_Expansion_Type__c !=Null && //GTMCLS-3824
                   (li.Apttus_Config2__Quantity__c < li.APTS_Baseline_Limit__c)){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decreasing the quantity value below the baseline quantity is not allowed for the LRNXE SKU'));
                    result.isSuccess = false;
                    return result;
                }
                //GTMCLS-3512 -  End

                //GTMCLS-3585 -  Start

                messagingQuantity = (li.Product_Code__c == APTPS_Constants.SKU_Code_LE_Messaging || li.Product_Code__c == APTPS_Constants.SKU_Code_LDP_Messaging) 
                    && messagingQuantity == null ? li.Apttus_Config2__Quantity__c : messagingQuantity;

                if((li.Product_Code__c == APTPS_Constants.SKU_Code_LE_Messaging || li.Product_Code__c == APTPS_Constants.SKU_Code_LDP_Messaging) && 
                   (messagingQuantity!= li.Apttus_Config2__Quantity__c) && li.Is_Ramped__c)
                  {
                     result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ramping the quantity on the Messaging SKU is not allowed. Please apply the same quantity across each line.'));
                     result.isSuccess = false;
                     return result;
                }
                //GTMCLS-3585 -  End
                
                //GTMCLS-5309 -  Start
                String cmuseProductCodes = NOLAutomationCS.getProdCodeStrforQtyRoundup();
                Set<String> cmuseProductCodesSet = new Set<String>(cmuseProductCodes.split(','));
                
                committedUsageQuantity = (cmuseProductCodesSet.contains(li.Product_Code__c)) &&
                    committedUsageQuantity == null ? li.Apttus_Config2__Quantity__c : committedUsageQuantity;
                
                if(cmuseProductCodesSet.contains(li.Product_Code__c) && 
                   (committedUsageQuantity!= li.Apttus_Config2__Quantity__c) && li.Is_Ramped__c)
                {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ramping the quantity on the Committed Usage SKU is not allowed. Please apply the same quantity across each line.'));
                    result.isSuccess = false;
                    return result;
                }
                //GTMCLS-5309 -  End
                

                // GTMCLS-3625 start
                Integer messagingQuantityNumber =  Integer.valueOf(messagingQuantity);
                Integer divisible =  Integer.valueOf(System.Label.DivisibleBy);
                if(divisible > 0 && messagingQuantityNumber > 0){
                    Integer remainder = math.mod(messagingQuantityNumber, divisible);
                    if(( li.Product_Code__c == APTPS_Constants.SKU_Code_LE_Messaging || li.Product_Code__c == APTPS_Constants.SKU_Code_LDP_Messaging ) && 
                         li.APTS_Expansion_Type__c == APTPS_Constants.STANDARD &&  li.APTS_Expansion_Type__c != null && remainder != 0  ) {
                         result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity for annual true up events must be in increments of 50K Messages - please update the quantity on the Messaging SKU.'));
                         result.isSuccess = false;
                         return result;
                    }
                }
                // GTMCLS-3625 end 

                // GTMCLS-5295 start
                Integer committedUsageQuantityNumber =  Integer.valueOf(committedUsageQuantity);
                Integer divisibleCmuse =  Integer.valueOf(System.Label.DivisibleBy);
                if(divisibleCmuse > 0 && committedUsageQuantityNumber > 0){
                    Integer remainderCmuse = math.mod(committedUsageQuantityNumber, divisibleCmuse);
                    if(cmuseProductCodesSet.contains(li.Product_Code__c) && 
                       li.APTS_Expansion_Type__c == APTPS_Constants.STANDARD &&  li.APTS_Expansion_Type__c != null && remainderCmuse != 0  ) {
                           result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity for annual true up events must be in increments of 50K - please update the quantity on the '+ li.Apttus_Config2__Uom__c +' SKU.'));
                           result.isSuccess = false;
                           return result;
                       }
                }
                // GTMCLS-5295 end 
                
                // GTMCLS-4022 -  Start
                if((li.Product_Code__c ==  APTPS_Constants.SKU_Code_LE_Messaging || li.Product_Code__c == APTPS_Constants.SKU_Code_LDP_Messaging ) &&
                  li.APTS_Expansion_Type__c != Null && 
                   li.Apttus_Config2__Quantity__c != null && li.APTS_Baseline_Quantity__c != null  &&
                   (li.Apttus_Config2__Quantity__c < li.APTS_Baseline_Quantity__c)){
                       result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decreasing the quantity value below the baseline quantity is not allowed for the MSG/LDPMSG SKU'));
                       result.isSuccess = false;
                       return result;
                   }
                // GTMCLS-4022 -  End

                // GTMCLS-5297 -  Start
                if((cmuseProductCodesSet.contains(li.Product_Code__c)) &&
                   li.APTS_Expansion_Type__c != Null && 
                   li.Apttus_Config2__Quantity__c != null && li.APTS_Baseline_Quantity__c != null  &&
                   (li.Apttus_Config2__Quantity__c < li.APTS_Baseline_Quantity__c)){
                       result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decreasing the quantity value below the baseline quantity is not allowed for the '+ li.Apttus_Config2__Uom__c +' SKU'));
                       result.isSuccess = false;
                       return result;
                   }
                // GTMCLS-5297 -  End

                // GTMCLS-5157 , GTMCLS-5183/5243 -  Start 
                if((li.Product_Code__c ==  APTPS_Constants.SKU_Code_LE_CandidateEngagement || li.Product_Code__c == APTPS_Constants.SKU_Code_LDP_CandidateEngagement || li.Product_Code__c == APTPS_Constants.BYOK || li.Product_Code__c == APTPS_Constants.LDPBYOK ) &&
                  li.APTS_Expansion_Type__c != Null && 
                   li.Apttus_Config2__Quantity__c != null && li.APTS_Baseline_Quantity__c != null  &&
                   (li.Apttus_Config2__Quantity__c < li.APTS_Baseline_Quantity__c)){
                       result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decreasing the quantity value below the baseline quantity is not allowed for the SKU'));
                       result.isSuccess = false;
                       return result;
                   }
                // GTMCLS-5157 -  End
                
        // GTMCLS-4407 -  Start
                if(li.Product_Code__c ==  APTPS_Constants.WGC && propObj.Apttus_Proposal__Opportunity__r.type != APTPS_Constants.OPTY_TYPE_EXPN){
                       wgcbundleattribute = li.APTS_WGCAttributeSelection__c;
                   }
                // GTMCLS-4407 -  End

                //GTMCLS-5500
                if(li.Apttus_Config2__Quantity__c != null && li.Apttus_Config2__Quantity__c < 1000 && WPM_VNDLY_SKUS_CONFIG!=NULL && WPM_VNDLY_SKUS_CONFIG.contains(li.Product_Code__c)){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Worker Profile Management Quantity must be at least 1,000'));
                       result.isSuccess = false;
                       return result;
                }
                if(li.Apttus_Config2__Quantity__c > 1 && li.Is_Ramped__c && li.APTS_PeriodNumber__c != 1 && li.APTS_PeriodNumber__c !=NULL && 
                mapVndlyEWMSTOWPreviousQuantity.containsKey(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name) &&
                (li.Apttus_Config2__Quantity__c < mapVndlyEWMSTOWPreviousQuantity.get(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name))){
                   result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Quantity may not be reduced during the Order Term. Please modify the Quantities to match YOY or apply increasing YOY Quantities'));
                   result.isSuccess = false;
                   return result;
                }   
                if(li.Apttus_Config2__Quantity__c > 1000 && li.Is_Ramped__c && li.APTS_PeriodNumber__c != 1 && li.APTS_PeriodNumber__c !=NULL && 
                mapVndlyWPMPreviousQuantity.containsKey(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name) &&
                (li.Apttus_Config2__Quantity__c < mapVndlyWPMPreviousQuantity.get(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name))){
                   result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Quantity may not be reduced during the Order Term. Please modify the Quantities to match YOY or apply increasing YOY Quantities'));
                   result.isSuccess = false;
                   return result;
                }  
                //GTMCLS-5500

            }


            //End GTMCLS-2266*/
            //GTMCLS-3833 Platform Stabilization
            result = APTPS_ValidateLinesCallbackService.AccountingCenterValidateLines(configId, currencyIsoCode,propObj,assetLines); // GTMCLS - 310 //GTMCLS – 1081

        }
        //GTMOM 2682 - End Here
        else {
            //GTMENT-2782 changes
            //if (cart.getConfigSO().APTS_IsCustomPricePending__c > 0) {
            /// result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, APTPS_Constants.getMessage('CUSTOM_PRICING_ERR_MSG')));
            //  result.isSuccess = false;
            //  return result;
            //}
        }
        // Show message to user for legacy quotes to refresh the screen.
        if (RuntimeContextcartmap != null && RuntimeContextcartmap.get('currentStep') != null && cart.getConfigSO().APTS_Proposal_Record_Type__c != APTPS_Constants.RT_PROP_PROPOSAL && RuntimeContextcartmap.get('currentStep').equalsignorecase('Savecart')) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Legacy_SpinnigWheel_ErrorMessage));
        }
        /******************* Start - GTMSM-1582 **********************************/

        //Validation for Sourcing User's Quantity at Cart Level
        //ID proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        list < Apttus_Config2.LineItem > allLines = cart.getLineItems();
        list < Apttus_Config2__LineItem__c > lineItems = new list < Apttus_Config2__LineItem__c > ();
        // List < Apttus_Proposal__Proposal__c > proposals = [SELECT id, APTS_Record_Type_Name__c, APTS_OpportunityType__c, APTS_Quote_Identifier__c, Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c // GTMSM-2337
        // FROM Apttus_Proposal__Proposal__c
        //  WHERE id = :proposalId LIMIT 1];
        final Boolean scoutQuote = propObj.APTS_Quote_Identifier__c; // GTMSM-2337
    Set<String> wgcallowedproducts = APTPS_ValidateLinesCallbackService.getWGCallowedProducts(wgcbundleattribute); // GTMCLS-4407
        // if (scoutQuote == True) {
        //GTMSM-2337 Start Code ////GTMCLS-1349 start
        //  Set<String> assetprd = new Set<String>();
        //  Set<String> assetprd1 = new Set<String>(); //GTMCLS-1313/1737
        // if(propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription'){
        // List<ID> listAccount = new List<ID>(); 
        // List<String> fieldnames = new List<String>{'APTS_Product_Code__c'};
        // listAccount.add(propObj.Apttus_Proposal__Account__c);
        // Apttus_Config2.CPQStruct.QueryAssetsRequestDO request = new Apttus_Config2.CPQStruct.QueryAssetsRequestDO();
        // request.AccountIds = listAccount;
        // request.FieldNames = fieldnames;
        // // call getAssetLineItems API
        // Apttus_Config2.CPQStruct.QueryAssetsResponseDO response = Apttus_Config2.AssetService.getAssetLineItems(request);
        // List<Apttus_Config2__AssetLineItem__c> listItems = response.AssetLineItems;
        // system.debug('Asset Lines'+listItems);
        // for(Apttus_Config2__AssetLineItem__c asstl:listItems) {
        //   assetprd.add(asstl.APTS_Product_Code__c);
        //     //GTMCLS-1313/1737
        //         if(propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription') {
        //             assetprd1.add(asstl.APTS_Product_Code__c); 
        //         } 
        //         //GTMCLS-1313/1737
        // }
        // }
        //GTMSM-2337 End Code ////GTMCLS-1349 End
        for (Apttus_Config2.LineItem lineItemMO: allLines) {
            lineItems.add(lineItemMO.getLineItemSO());
        }
        Set < String > cartlineprod = new Set < String > (); // GTMSM-2336
        Set < String > renewalprods = new Set < String > (); // GTMSM-2259
        Map < String, String > lineItemToTierMap = new Map < String, String > (); // GTMCLS-2717

        for (Apttus_Config2__LineItem__c li: lineItems) {

             //GTMCLS-4456 Start
            //GTMCLS-4631 Bypass Validation if Quantity <= 10
            if(li.Apttus_Config2__Quantity__c > 10 && li.Is_Ramped__c && li.APTS_PeriodNumber__c != 1 && li.APTS_PeriodNumber__c !=NULL && 
            mapPreviousQuantity.containsKey(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name) &&
            (li.Apttus_Config2__Quantity__c < mapPreviousQuantity.get(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name))){
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decreasing the quantity for Prism essentials is not allowed'));
                result.isSuccess = false;
                return result;
            }
            //GTMCLS-4456 End
      
           // GTMCLS-4156 Starts
           // GTMCLS-4630 Bypass Validation if Quantity <= 1
            if(li.Apttus_Config2__Quantity__c > 1 && li.Is_Ramped__c && li.APTS_PeriodNumber__c != 1 && li.APTS_PeriodNumber__c !=NULL && 
            mapPreviousPracuQuantity.containsKey(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name) &&
            (li.Apttus_Config2__Quantity__c < mapPreviousPracuQuantity.get(String.valueOf(li.APTS_PeriodNumber__c - 1) + li.Apttus_Config2__OptionId__r.Name))
              && (pracuValidationSKUSet!=NULL && pracuValidationSKUSet.contains(li.Product_Code__c))){
                  result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.PRACU_Quantity_Validation_Error_Message));
                  result.isSuccess = false;
                  return result;
            }
            // GTMCLS-4156 Ends
      
      
            //GTMCLS-4456 Start & GTMCLS-4156 Starts
            if(propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPTY_TYPE_EXPN && li.APTS_Expansion_Type__c!=NULL && li.Apttus_Config2__Quantity__c!=NULL &&
               li.APTS_Baseline_Quantity__c !=NULL && li.APTS_Baseline_Quantity__c > 0 && li.Apttus_Config2__Quantity__c < li.APTS_Baseline_Quantity__c){
                   if(li.Product_Code__c == APTPS_Constants.PRA03 || li.Product_Code__c == APTPS_Constants.LDPPRA03 || (pracuValidationSKUSet!=NULL && pracuValidationSKUSet.contains(li.Product_Code__c))){
                       result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.Decrease_Baseline_Quantity_Validation_Error_Message));
                       result.isSuccess = false;
                       return result; 
                   }
               }         
            // GTMCLS-4156 Ends
                
            if(propObj.Apttus_Proposal__Opportunity__r.type == 'Expansion (Addtl EEs)' && (li.Product_Code__c == APTPS_Constants.LDPPRA03 ||
            li.Product_Code__c == APTPS_Constants.PRA03) &&
            li.Apttus_Config2__Quantity__c !=NULL && ((li.Apttus_Config2__Quantity__c / 10) != (Integer.valueOf(li.Apttus_Config2__Quantity__c/10)))){
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity for annual true up events must be in increment of 10M published data rows - please update the quantity on the prism analytics essentials SKU'));
                        result.isSuccess = false;
                        return result;
            }
            //GTMCLS-4456 End
            // GTMSM-2259 start code
                if(propObj.Apttus_Proposal__Opportunity__r.type == 'Renewal' && li.Apttus_Config2__LineStatus__c != 'Cancelled')
                {
                renewalprods.add(li.Product_Code__c);
            }
            // GTMSM-2259 End code
            cartlineprod.add(li.Product_Code__c); //// GTMSM-2336
            lineItemToTierMap.put(li.Product_Code__c, li.Usage_Tier__c); // GTMCLS-2717
                        // Start GTMCLS-2988 
             if(!li.Apttus_Config2__IsPrimaryLine__c  &&  
                            li.Apttus_Config2__LineType__c == APTPS_Constants.LINE_OPTION   &&
                            (li.Product_Code__c==APTPS_Constants.ADAPTIVE_BASE_USER ||li.Product_Code__c==APTPS_Constants.ADAPTIVE_BASEPLUS_USER ||li.Product_Code__c==APTPS_Constants.ADAPTIVE_BUNDLE_USER || li.Product_Code__c == APTPS_Constants.STRATEGIC_SRC_USER_ADD_LE || li.Product_Code__c == APTPS_Constants.STRATEGIC_SRC_USER_ADD_LDP) && li.Apttus_Config2__Quantity__c < primaryQuantity.get(li.Product_Code__c)  && li.Apttus_Config2__Quantity__c !=1 //GTMCLS-3808
                            ) {  
                                 result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Quantity of Additional Users may not be reduced during the Order Term. Please modify the Quantities to match YOY or apply increasing YOY Quantities'));  
                                 result.isSuccess = false;                               
                                 return result;  
                            }
                 //end  GTMCLS-2988
            //GTMSM-2336 start code
            //GTMCLS-2340 //GTMCLS-4267
                if(bundleprod.contains(li.Product_Code__c) && !Excption.contains('Bypass Sourcing SKU Requirements') &&  li.APTS_Baseline_Quantity__c !=1 && (propObj.Apttus_Proposal__Opportunity__r.type == 'Expansion (Addtl EEs)' || (propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription' &&  propObj.Apttus_Proposal__Opportunity__r.Sub_Type__c == 'Growth Event') ) )
                {
                if (propObj.APTS_SKU_Pricing_Model__c == 'Lifecycle Deployment Program') {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Base line Quantity cannot be changed for Strategic Sourcing Sku\'s except Strategic Sourcing User (Additional) - LDP'));
                    }
                    else if(propObj.APTS_SKU_Pricing_Model__c == 'Large Enterprise'){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Base line Quantity cannot be changed for Strategic Sourcing Sku\'s except Strategic Sourcing User (Additional)'));
                }
                result.isSuccess = false;
                return result;
            }
            //GTMCLS-2340 //GTMCLS-4267
                if(bundleprod.contains(li.Product_Code__c) && !Excption.contains('Bypass Sourcing SKU Requirements') && li.Apttus_Config2__Quantity__c != 1 && (propObj.Apttus_Proposal__Opportunity__r.type == 'Expansion (Addtl EEs)' || (propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription' &&  propObj.Apttus_Proposal__Opportunity__r.Sub_Type__c == 'Growth Event') ))
                {
                if (propObj.APTS_SKU_Pricing_Model__c == 'Lifecycle Deployment Program') {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be changed for Strategic Sourcing Sku\'s except Strategic Sourcing User (Additional) - LDP'));
                    }
                    else if(propObj.APTS_SKU_Pricing_Model__c == 'Large Enterprise'){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be changed for Strategic Sourcing Sku\'s except Strategic Sourcing User (Additional)'));
                }
                result.isSuccess = false;
                return result;
            }
            //GTMCLS-4267
                if(bundleprod.contains(li.Product_Code__c) && li.Apttus_Config2__AssetQuantity__c != 1 && !Excption.contains('Bypass Sourcing SKU Requirements') && propObj.Apttus_Proposal__Opportunity__r.type == 'Renewal' && li.Apttus_Config2__LineStatus__c !='New')
                {
                if (propObj.APTS_SKU_Pricing_Model__c == 'Lifecycle Deployment Program') {
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Asset Quantity cannot be changed for Strategic Sourcing Sku\'s except Strategic Sourcing User (Additional) - LDP'));
                    }
                    else if(propObj.APTS_SKU_Pricing_Model__c == 'Large Enterprise'){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Asset Quantity cannot be changed for Strategic Sourcing Sku\'s except Strategic Sourcing User (Additional)'));
                }
                result.isSuccess = false;
                return result;
            }
            //End GTMSM-2336 
      // GTMCLS-4409 -  Start
            if (!Excption.contains('Bypass WGC Inclusion Rule')){  
                // GTMCLS-4407 -  Start
                if(wgcallowedproducts != null && wgcallowedproducts.size() > 0 && 
                   li.Product_Code__c != null && li.Product_Code__c != APTPS_Constants.WGC && 
                   !wgcallowedproducts.contains(li.Product_Code__c)){
                    result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some or all of the SKUs selected in the cart or in the asset are not compatible with the selected Workday Government Cloud bundle - please remove SKUs that are outside of the selected bundle.'));
                    result.isSuccess = false;
                    return result;
                }
                // GTMCLS-4407 -  End
            }
            // GTMCLS-4409 -  End      

            if (li.APTS_Configuration_Type__c == PRODUCT_CONFIG_STD && (li.Apttus_Config2__Quantity__c == 0 || li.Apttus_Config2__Quantity__c == null) && scoutQuote == True) { // GTMSM-2336
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ramp Option Quantity should not be zero'));
                result.isSuccess = false;
                return result;
            }
        }
        //GTMSM-2337 Start Code //GTMCLS-4267
        if (cartlineprod.contains('SRCUSR') && !Excption.contains('Bypass Sourcing SKU Requirements') && !cartlineprod.contains('SRCESS') && !cartlineprod.contains('SRCEXP') && propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription' && !assetprd.contains('SRCESS') && !assetprd.contains('SRCEXP')) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Additional sourcing Sku cannot be selected if there is no Sourcing Expert or Essentials in the Cart or Asset lines'));
            result.isSuccess = false;
            return result;
            }
            else if(cartlineprod.contains('LDPSRCUSR') && !Excption.contains('Bypass Sourcing SKU Requirements') && !cartlineprod.contains('LDPSRCESS') && !cartlineprod.contains('LDPSRCEXP') && propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription' && !assetprd.contains('LDPSRCESS') && !assetprd.contains('LDPSRCEXP')){
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Additional sourcing Sku cannot be selected if there is no Sourcing Expert or Essentials in the Cart or Asset lines'));
            result.isSuccess = false;
            return result;
        }
        //GTMCLS-1313/1737/4267 - Start Code 
        if (isProcurementEssentialAdded(cartlineprod, assetprd1, propObj) && !Excption.contains('Bypass Sourcing SKU Requirements')) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'For Strategic Sourcing Contracts and Strategic Sourcing Supplier Mgmt : Strategic Sourcing Essential or Procurement should be included'));
            result.isSuccess = false;
            return result;
        }

        //GTMCLS-1313/1737 - End Code
        //GTMSM-2337 End Code
        // Start GTMCLS-2059
        
        //GTMCLS-2923 Start
            if((((cartlineprod.contains('PLNFI') || cartlineprod.contains('LDPPLNFI')) && (!(cartlineprod.contains('LDPPLNF')) && !(cartlineprod.contains('PLNF'))) 
             && !((AllAssetProducts.contains('LDPPLNF') || AllAssetProducts.contains('PLNF')) && propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription'))  || 
              ((cartlineprod.contains('PLNWI') || cartlineprod.contains('LDPPLNWI')) && (!(cartlineprod.contains('LDPPLNW')) && !(cartlineprod.contains('PLNW'))) 
              && !((AllAssetProducts.contains('LDPPLNW') || AllAssetProducts.contains('PLNW')) && propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription'))  ||
              ((cartlineprod.contains('PLNSI') || cartlineprod.contains('LDPPLNSI')) && (!(cartlineprod.contains('LDPPLNS')) && !(cartlineprod.contains('PLNS')))
              && !((AllAssetProducts.contains('LDPPLNS') || AllAssetProducts.contains('PLNS')) && propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription'))  ||
              ((cartlineprod.contains('PLNXI') || cartlineprod.contains('LDPPLNXI')) && (!(cartlineprod.contains('LDPPLNX')) && !(cartlineprod.contains('PLNX')))
              && !((AllAssetProducts.contains('LDPPLNX') || AllAssetProducts.contains('PLNX')) && propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription'))) 
              && !(Excption.contains('Bypass Adaptive Instance User Restriction')))     // GTMCLS-2796
        {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
            result.isSuccess = false;
            return result;
        }
        
        
        if(cartlineprod.contains('APLNU') && 
        ((!(cartlineprod.contains('APLN')) && !(AllAssetProducts.contains('APLN'))) && (propObj.Apttus_Proposal__Opportunity__r.type != 'Add-on Subscription') &&  //GTMCLS-3120 //GTMCLS-3142
        !(Excption.contains('Bypass Adaptive Base User Restriction'))))
        {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
            result.isSuccess = false;
            return result;
        }
        
        
        if(cartlineprod.contains('APLNPU') && 
        ((!(cartlineprod.contains('APLNP')) && !(AllAssetProducts.contains('APLNP'))) && (propObj.Apttus_Proposal__Opportunity__r.type != 'Add-on Subscription') &&        //GTMCLS-3120 //GTMCLS-3142
        !(Excption.contains('Bypass Adaptive Base Plus User Restriction'))))
        {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
            result.isSuccess = false;
            return result;
        }
            
        if(cartlineprod.contains('APLNUR') && (propObj.Apttus_Proposal__Opportunity__r.type != 'Add-on Subscription') &&        //GTMCLS-3120
                (propObj.Apttus_Proposal__Opportunity__r.type != 'Expansion (Addtl EEs)') && ((!(cartlineprod.contains('APLNR')) && !(AllAssetProducts.contains('APLNR'))) &&  //GTMCLS-3142
                !(Excption.contains('Bypass Adaptive Planning Bundle User Restriction'))))
        {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
            result.isSuccess = false;
            return result;
        }
    //GTMCLS-2923 End

        // GTMCLS-5499 Start
        //system.debug('<<cartlineprod>>'+cartlineprod+ '>>AllAssetProducts>>'+AllAssetProducts);
        if((propObj.APTS_OpportunityType__c == APTPS_Constants.Add_ON_SUBSCRIPTION || propObj.APTS_OpportunityType__c == APTPS_Constants.OPP_TYPE_RENEWAL) && 
            cartlineprod.contains(APTPS_Constants.VNDLYTRN1) && !(cartlineprod.contains(APTPS_Constants.VNDLYTRN10)) && !(cartlineprod.contains(APTPS_Constants.VNDLYTRN5)) && !(AllAssetProducts.contains(APTPS_Constants.VNDLYTRN10)) && !(AllAssetProducts.contains(APTPS_Constants.VNDLYTRN5)) ){
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a VNDLY Initial User option. User cannot select the (1 Additional User) option alone, if an Initial User option wasnt purchased by the Customer.'));
            result.isSuccess = false;
            return result;
        }
        //GTMCLS-5499 End
        
    //GTMCLS-3142 Start // GTMCLS-3298 Commented
      /*  if(cartlineprod.contains('APLNUR') && (propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription') &&
                ((!(cartlineprod.contains('APLNR')) && !(AllAssetProducts.contains('APLNR'))) && 
                !(Excption.contains('Bypass Adaptive Planning Bundle User Restriction'))))
        {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
            result.isSuccess = false;
            return result;
        } */
        
        if(propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription')
        {    
            if(cartlineprod.contains('APLNU') && !(cartlineprod.contains('APLN')) && !(AllAssetProducts.contains('APLN')) && !(Excption.contains('Bypass Adaptive Base User Restriction')))
            {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
                    result.isSuccess = false;
                    return result;
            }
            
              if(cartlineprod.contains('APLNPU') && !(cartlineprod.contains('APLNP')) && !(AllAssetProducts.contains('APLNP')) && !(Excption.contains('Bypass Adaptive Base Plus User Restriction')))
            {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
                    result.isSuccess = false;
                    return result;
            }
        }
        
        
    //GTMCLS-3142 End
      /*  if (propObj.Apttus_Proposal__Opportunity__r.type == 'Add-on Subscription' && !Excption.contains('Bypass Adaptive Add On Restriction')) { //GTLCLS-2159
            if ((cartlineprod.contains('PLNFI') && !(cartlineprod.contains('LDPPLNF') || cartlineprod.contains('PLNF')) && !(assetprd1.contains('LDPPLNF') || assetprd1.contains('PLNF'))) ||
                (cartlineprod.contains('PLNWI') && !(cartlineprod.contains('LDPPLNW') || cartlineprod.contains('PLNW')) && !(assetprd1.contains('LDPPLNW') || assetprd1.contains('PLNW'))) ||
                (cartlineprod.contains('PLNSI') && !(cartlineprod.contains('LDPPLNS') || cartlineprod.contains('PLNS')) && !(assetprd1.contains('LDPPLNS') || assetprd1.contains('PLNS'))) ||
                (cartlineprod.contains('PLNXI') && !(cartlineprod.contains('LDPPLNX') || cartlineprod.contains('PLNX')) && !(assetprd1.contains('LDPPLNX') || assetprd1.contains('PLNX'))) ||
                   (cartlineprod.contains('APLNU') && !(cartlineprod.contains('APLN')) && !(assetprd1.contains('APLN')) && !(Excption.contains('Bypass Adaptive Base User Restriction'))) ||    //GTMCLS-3120
                   (cartlineprod.contains('APLNPU') && !(cartlineprod.contains('APLNP')) && !(assetprd1.contains('APLNP')) && !(Excption.contains('Bypass Adaptive Base Plus User Restriction')))) {
                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select the appropriate prerequisite SKU'));
                result.isSuccess = false;
                return result;
            }
        } */ // Commented // GTMCLS-3142
        // END GTMCLS-2059
        // GTMSM-2259 start code //GTMCLS-4267
        if (((renewalprods.contains('SRCESS') && !Excption.contains('Bypass Sourcing SKU Requirements') &&  (renewalprods.contains('SRC') || renewalprods.contains('SRCEXP'))) || (renewalprods.contains('LDPSRCESS') && (renewalprods.contains('LDPSRC') || renewalprods.contains('LDPSRCEXP'))))) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sourcing Essential cannot be selected with Sourcing Expert or Sourcing Enterprise'));
            result.isSuccess = true;
            return result;
        }
        if (((renewalprods.contains('SRCEXP') && !Excption.contains('Bypass Sourcing SKU Requirements') && (renewalprods.contains('SRC') || renewalprods.contains('SRCINT') || renewalprods.contains('SRCCNT') || renewalprods.contains('SRCSM'))) || (renewalprods.contains('LDPSRCEXP') && (renewalprods.contains('LDPSRC') || renewalprods.contains('LDPSRCINT') || renewalprods.contains('LDPSRCCNT') || renewalprods.contains('LDPSRCSM'))))) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sourcing Expert can not be included with Sourcing Essentials, Sourcing Enterprise, Strategic Sourcing Intake, Strategic Sourcing Contracts and Strategic Sourcing Supplier Mgmt on the same quote.'));
            result.isSuccess = true;
            return result;
        }
        if (((renewalprods.contains('SRC') && !Excption.contains('Bypass Sourcing SKU Requirements') && (renewalprods.contains('SRCESS') || renewalprods.contains('SRCEXP') || renewalprods.contains('SRCINT') || renewalprods.contains('SRCCNT') || renewalprods.contains('SRCUSR') || renewalprods.contains('SRCSM'))) || (renewalprods.contains('LDPSRC') && (renewalprods.contains('LDPSRCESS') || renewalprods.contains('LDPSRCEXP') || renewalprods.contains('LDPSRCINT') || renewalprods.contains('LDPSRCCNT') || renewalprods.contains('LDPSRCUSR') || renewalprods.contains('LDPSRCSM'))))) {
            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sourcing Enterprise cannot be selected with other products'));
            result.isSuccess = true;
            return result;
        }
        // GTMSM-2259 End code
        /*************************************GTMCLS-2717 start********************************************************/       
    
        if (!Excption.contains('Bypass tier alignment requirement for Labor Optimization') 
            && (propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_NET_NEW 
                || propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE 
                || propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_RENEWAL
                || 'Expansion (Addtl EEs)'.equalsIgnoreCase(propObj.Apttus_Proposal__Opportunity__r.type)//GTMCLS-2889
            )
        ) {
            if ((cartlineprod.contains('SCLO') &&
                    cartlineprod.contains('SC') &&
                    lineItemToTierMap != NULL &&
                    lineItemToTierMap.get('SCLO') != lineItemToTierMap.get('SC')) ||
                (cartlineprod.contains('LDPSCLO') &&
                    cartlineprod.contains('LDPSC') &&
                    lineItemToTierMap != NULL &&
                    lineItemToTierMap.get('LDPSCLO') != lineItemToTierMap.get('LDPSC'))
            ) {

                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, 
                        'The same tier must be selected for Scheduling and Labor Optimization.'));
                result.isSuccess = false;
                return result;
            }
            //GTMCLS-2889- Start
            if ((cartlineprod.contains('SCLO') &&
                    cartlineprod.contains('SC')) ||
                (cartlineprod.contains('LDPSCLO') &&
                    cartlineprod.contains('LDPSC') )
            ) {
                result.isSuccess = true;
                return result;
            }
            //GTMCLS-2889-End

            if ((cartlineprod.contains('SCLO') &&
                    assetprdAll.contains('SC') &&
                    lineItemToTierMap != NULL &&
                    assetToTierMap != NULL &&
                    lineItemToTierMap.get('SCLO') != assetToTierMap.get('SC')) ||
                (cartlineprod.contains('LDPSCLO') &&
                    assetprdAll.contains('LDPSC') &&
                    lineItemToTierMap != NULL &&
                    assetToTierMap != NULL &&
                    lineItemToTierMap.get('LDPSCLO') != assetToTierMap.get('LDPSC'))
            ) {

                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'The same tier must be selected for Scheduling and Labor Optimization.'));
                result.isSuccess = false;
                return result;
            } 

        }


        /***************************************GTMCLS-2717 ends*********************************************************/

        return result;

        /******************* End - GTMSM-1582 **********************************/
    }

    /**
     * @GTMCLS – 1313/1737
     * @description : Procurement or Essentials required for Contract and Supplier Mananagement if selected in CART     
     */
    private static Boolean isProcurementEssentialAdded(
        Set < String > cartlineprod,
        Set < String > assetprd1,
        Apttus_Proposal__Proposal__c propObj
    ) {

        return (
            cartlineprod.contains(SUPPLIER_LE_CODE) 
            || cartlineprod.contains(SUPPLIER_LDP_CODE) 
            || cartlineprod.contains(CONTRACT_LE_CODE ) 
            || cartlineprod.contains(CONTRACT_LDP_CODE )
            )
            /* Start GTMCLS-1990 */
            && (!cartlineprod.contains(ESSENTIALS_LE_CODE) && !assetprd1.contains(ESSENTIALS_LE_CODE))
            && (!cartlineprod.contains(ESSENTIALS_LDP_CODE)  && !assetprd1.contains(ESSENTIALS_LDP_CODE))
            && (!cartlineprod.contains(PRO_LE_CODE) && !assetprd1.contains(PRO_LE_CODE))
            && (!cartlineprod.contains(PRO_LDP_CODE)  && !assetprd1.contains(PRO_LDP_CODE))
            /* End GTMCLS-1990 */
            &&
            (
                propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_NET_NEW  
                || 
                propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_TYPE_RENEWAL 
                || 
                propObj.Apttus_Proposal__Opportunity__r.type == APTPS_Constants.OPP_ADDON_TYPE
            );

    }

    /**
     * Callback to validate the given list ramp line items
     * @param cart the cart object associated with the ramp line items
     * @param rampLineItems the list of ramp line items
     * @return the validation result
     */
    global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, List < Apttus_Config2.LineItem > rampLineItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        result.isSuccess = true;
        return result;

    }

    /**
     * Callback to validate the given list of asset items
     * @param cart the cart object associated with the asset items
     * @param assetItems the list of asset items
     * @return the validation result
     */
    global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart, List < Apttus_Config2__TempRenew__c > assetItems) {
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        result.isSuccess = true;
        return result;
    }

}