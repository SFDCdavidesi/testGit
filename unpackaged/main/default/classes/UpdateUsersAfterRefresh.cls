global class UpdateUsersAfterRefresh implements SandboxPostCopy  {
    //US-0008143 
    //PURPOSE: CREATE a class that will be executed after ever Sandbox Refresh updating profile & email from 
    //Dev Team and Hive team
    public static final set<String> LIST_OF_USERS= new set<String>{
        'Nirmala Nandagopal',
            'Jasmine Aulakh',
            'Robert Maier',
            'David Herrero',
            'Deep Grewal',
            'Simon Golledge',
            'Cristina Anghenie',
            'Andy Clark',
            'Tenzin Tsagong'};
    public static final String QUERY_USERS='select id,email,profileid from user where isactive=true and ( email like \'%gaea-sys%\' or name in :LIST_OF_USERS)';
    
    
    global void runApexClass(SandboxContext context) {
        
        System.debug('Hello Tester Pester ' + context.organizationId() + ' ' + context.sandboxId() + context.sandboxName());
        
        
        Map<String,id> mapProfiles = new Map<string,id>();
        for (Profile p :[select id,name from profile]){
            mapProfiles.put(p.name,p.id);
        }
        List<User> listOfUsers = Database.query(QUERY_USERS);
        
        for (User u : listOfUsers){
            u.profileId=mapProfiles.get('System Administrator');
            u.email=u.email.left(u.email.indexof('invalid')-1);
            
        }
        
        Database.update( listOfUsers,false);
        
        
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        
        Database.update(listOfUsers,dlo); 
        
    }
}