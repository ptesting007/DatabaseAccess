#import <Foundation/Foundation.h>
#import <sqlite3.h>
//#error add framework libsqlite3.0.dylib
@interface DatabaseAccess : NSObject {
    
}
//To check and create new database for application
+(void)checkAndCreateDatabase;
//Get All the device listing
+(NSMutableArray *)getWordMeaning:(NSString *)strWord;
//To add new device in to table
+(void)writeDataToDeviceList:(NSString *)GSMNumber deviceName:(NSString *)deviceNm;
//To remove Device which are not required
+(BOOL)deleteFromDeviceList:(int)pk;
