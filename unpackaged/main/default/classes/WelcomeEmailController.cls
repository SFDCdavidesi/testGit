/*********************************************************************************************************************************
@ Class:         WelcomeEmailController
@ Version:       1.0
@ Author:        Sovantheany.dim(sovantheany.dim@gaea-sys.com)
@ Purpose:       US-0011571 - Welcome email has been enabled which will send same email template to every Sellers irrespective of region and type of Seller
@				 used by vf template name : Add_User_Welcome_Email_Template 
----------------------------------------------------------------------------------------------------------------------------------
@ Change history: 29.03.2022 / Sovantheany.dim(sovantheany.dim@gaea-sys.com)
*********************************************************************************************************************************/
public with sharing class WelcomeEmailController {
    public Contact cont { get; set; }
	public static String soqlUser = 'select userName from User where ContactId =: contId';
    /*****************************************************************************************************************************
    @ Method:       getUsers
    @ Author:       sovantheany Dim (sovantheany.dim@gaea-sys.com)
    @ Purpose:      US-0011571 - Welcome email has been enabled which will send same email template to every Sellers irrespective of region and type of Seller
    @               get UserName
    ------------------------------------------------------------------------------------------------------------------------------
    @ Change history:  29.03.2022 / sovantheany dim / US-0011571 Created the method.
    @*****************************************************************************************************************************/
    public List<User> getUsers() {
           List<User> users = new List<User>();
           String contId = cont.Id;
           users = Database.query(soqlUser); 
        return users;
    }
}