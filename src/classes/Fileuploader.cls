public class Fileuploader {
    
    private final Integer MAX_SIZE          = 131072; // 128Kb
    private final Integer MAX_LENGTH_NAME   = 71;// File Length 
    private final String  ERROR_NO_SAVE     = 'Please upload file.'; // Error Message on No Save
    private final String  ERROR_IMG_TYPE    = 'The image must be .jpg, .gif or .png';    // Error Message for Non Allowed Type 
    
    //List Of Images Allowed 
    private Set<String> imagesTypes         = new Set<String> {'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png', 'image/gif'};
        //Not Allowd Type 
        private Set<String> notAllowedTypes     = new Set<String> {'application/octet-stream' , 'image/bmp'};
            
            public Attachment   newAttach           { set; get; }
    public Attachment   file                { set; get; }
    private String      parentId            { set; get; }
    public String       postAction          { set; get; }
    public String       error               { set; get; }
    public Boolean      hasPicture          { set; get; }
    
    public Fileuploader( ApexPages.StandardController stdController ){
        
        this.parentId       = stdController.getId();
        this.hasPicture     = false;
        this.newAttach      = new Attachment();
        this.error          = '';
        
        List<Attachment> attList = [ Select ParentId, Name, Id, ContentType, BodyLength From Attachment where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
        if( attList.size() > 0 ){
            this.file               = attList.get( 0 );
            this.hasPicture         = true;
        }
    }
    public PageReference uploadAction(){
        
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        if( this.validate() ){
            return ( this.saveCurrentPicture() ) ? thePage : null;
        }
        else{
            this.newAttach = new Attachment();
            return null;
        }
    }
    
    public Boolean saveCurrentPicture(){
        Savepoint sp = Database.setSavepoint();
        try{
            delete [ Select Id From Attachment where ParentId =: this.parentId and name = 'Contact Picture' limit 1 ];
            this.newAttach.parentId = this.parentId;
            this.newAttach.name = 'Contact Picture';
            insert this.newAttach;
            return true;
        } 
        catch( Exception e ){
            this.error += ERROR_NO_SAVE+'<br/>';
            Database.rollback( sp );
            return false;
        }
    }
    
    public PageReference deleteAction(){
        
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        delete this.file;
        return thePage;
    }
    
    private Boolean validate(){
        Boolean ret = true;
        this.error = '';
        if( !imagesTypes.contains( newAttach.ContentType ) ){
            this.error += ERROR_IMG_TYPE+'<br/>';
            ret = false;
        }
        return ret;
    }
    
    public PageReference cancel(){
        PageReference thePage = new PageReference( '/'+ parentId );
        thePage.setRedirect( true );
        return thePage;
    }
    
    
}