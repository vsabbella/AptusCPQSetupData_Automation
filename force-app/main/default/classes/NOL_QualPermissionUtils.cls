/*
    Name            : NOL_QualHelper
    Author          : Bhoopender Pal Singh
    Release         : 1.0
    Description     : This class contains business logics for permissions
    Functionality   :   
    Created         : Sep-24-2019
                      
    Modification History:
    Date            Author                  Change  
    Sep 24, 2019    Bhoopender Pal Singh    Refactored: Moved all permissions relevant NOL code, as mentioned below, from 'NOL_QualHelper.cls' and 'NOL_QualificationFormCtrl' to here
    Sep 13, 2019    Bhoopender Pal Singh    GTMSER-1965: NOL - Phase 2 - (1) Create Qualification Form Record on Prod Qual  
    Oct 21, 2019    Amil Hussain            GTMSER2703: To allow fit values access to Systm Admin and Data Admin profiles in FIT_EDITABLE_PROFILES_SET
    Nov 06, 2019    Bhoopender Pal Singh    Moved GTMSER-2703 related code to Controller so that all related code for that ticket can be at same place.
    Nov 15, 2019    Bhoopender Pal Singh    GTMSER-3131: UAT - AC#4 - If Status = Clarification Needed, on the Qual Form UI, BDM Fit and PreSales Fit should be Read-Only
*/

public class NOL_QualPermissionUtils {
    public static String loggedInProfileName{get;set;}
    public static boolean isEditAccess;
    //GTMSER-1965 - AC#4 - Check Edit/Read permissions
    public enum QualFormAccess {IS_ACCESSIBLE, IS_UPDATEABLE}  
    
    //GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    public enum FitTypes {SOLUTIONS_CONSULTANT, BDM}  
    public static final String PROFILE_OF_SOLUTION_CONSULTANT = 'Solutions Consultant';
    public static final String PROFILE_OF_BDM = 'Business Development Manager';
    private static final set<String> FIT_EDITABLE_PROFILES_SET = new set<String> {'Sales/Ops Admin', 'Services Ops', 'Services Ops Admin', 'Renewals', 'System Administrator', 'Data Administrator'};

    //GTMSER-1965 - AC#4 - Check Edit/Read permissions
    public static Boolean checkQualFormAccessible(QualFormAccess qualFormAccess) {
        Boolean isAccessible = false;

        switch on qualFormAccess {
            when IS_ACCESSIBLE {
                isAccessible = Schema.sObjectType.Product_Detail__c.IsAccessible();
            } when IS_UPDATEABLE {
                isAccessible = Schema.sObjectType.Product_Detail__c.IsUpdateable();
            }
        }

        return isAccessible; 
    } 

    /*
    * GTMSER-2152: NOL - Phase 2 - (4) PreSales & BDM Fit Calculations
    * Who can edit "PreSales Customer Fit" and "BDM Fit":
    *   Users: Solution Consultant users and their managers
    *          Business Development Manager users and their managers
    *   Profiles: Sales/Ops Admin, Services Ops, Services Ops Admin, Renewals
    */
    public static list<FitTypes> getEditableFits(String status) {
        list<FitTypes> fitTypeList = new list<FitTypes>();
        Id userId = UserInfo.getUserId();
        Id userProfileId = UserInfo.getProfileId();

        if(status != 'Product / Services Review' && status != 'Clarification Needed' && status != 'Executive Committee Review' && status != 'Approved - With Restrictions'
             && status != 'Approved - No Restrictions' && status != 'Denied' && status != 'Rejected' && status != 'Approved') { //GTMSER-3131 and GTMSER-3149

            //If current user has any of these profiles - Sales/Ops Admin, Services Ops, Services Ops Admin, Renewals
            for(Profile profileRec : [SELECT Id FROM Profile WHERE Name IN: FIT_EDITABLE_PROFILES_SET AND Id =: userProfileId]) {
                fitTypeList.add(FitTypes.SOLUTIONS_CONSULTANT);
                fitTypeList.add(FitTypes.BDM);
            }

            //If current user is Solution Consultant user or BDM user or manager of such user
            if(fitTypeList.isEmpty()) {            
                String profileName;

                //If current user is Solution Consultant user or BDM user
                for(Profile profileRec : [SELECT Id, Name FROM Profile WHERE Name IN (:PROFILE_OF_SOLUTION_CONSULTANT, :PROFILE_OF_BDM) AND Id =: userProfileId]) {
                    profileName = profileRec.Name;
                }

                //If current user is manager of a Solution Consultant user or BDM user
                if(String.isBlank(profileName)) {
                    for(User userRec : [SELECT Id, Profile.Name FROM User WHERE Profile.Name IN (:PROFILE_OF_SOLUTION_CONSULTANT, :PROFILE_OF_BDM) AND ManagerId =: userId]) {
                        profileName = userRec.Profile.Name;
                    }
                }

                if(String.isNotBlank(profileName)) {
                    if(profileName.equals(PROFILE_OF_SOLUTION_CONSULTANT)) {
                        fitTypeList.add(FitTypes.SOLUTIONS_CONSULTANT);

                    } else if(profileName.equals(PROFILE_OF_BDM)) {
                        fitTypeList.add(FitTypes.BDM);
                    }
                }
            }
        }

        return fitTypeList;
    }
}