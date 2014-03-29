#import "DatabaseAccess.h"
#import "NSString+HTML.h"
@implementation DatabaseAccess
//#error reneme the database name
NSString *databasePath;
NSString *databaseName = @"localDb.sqlite";

//#error call these method from app delegate (applicationDidFinishLaunching) method.
//To check and create new database for application
+(void)checkAndCreateDatabase {
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [[NSString alloc] initWithFormat:@"%@",[documentsDir stringByAppendingPathComponent:databaseName]];
    
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:databasePath];
	if(success) return;
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}
//Get All the device listing
+(NSMutableArray *)getWordMeaning:(NSString *)strWord {
    sqlite3 *database;
	NSMutableArray *arrTemp = [[[NSMutableArray alloc] init] autorelease];
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		NSString *tempSQL = [[NSString alloc] initWithFormat:@"SELECT * FROM tblWordList WHERE UPPER(Word) in (%@)", strWord];
		const char *sqlStatement = [tempSQL cStringUsingEncoding:NSUTF8StringEncoding];
		[tempSQL release];
        
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                int pk = (int)sqlite3_column_int(compiledStatement, 0);
				NSString *strWord = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *strMeaning = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				
				NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:[NSString stringWithFormat:@"%i", pk] forKey:@"PRIMARYKEY"];
				[tempDic setObject:strWord forKey:@"WORD"];
				[tempDic setObject:strMeaning forKey:@"MEANING"];

				[arrTemp addObject:tempDic];
				[tempDic release];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return arrTemp;
}
//To add new device in to table
+(void)writeDataToDeviceList:(NSString *)GSMNumber deviceName:(NSString *)deviceNm {
    sqlite3 *database;
	//databasePath = [self getDBPath];
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *tempSQL = [[NSString alloc] initWithFormat:@"INSERT INTO DeviceList values(NULL, '%@', '%@', '')",GSMNumber, deviceNm];
        const char *sqlStatement = [tempSQL cStringUsingEncoding:NSUTF8StringEncoding];
        [tempSQL release];
        
        sqlite3_stmt *compiledStatement;
        sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
        sqlite3_step(compiledStatement);
        sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}
//To remove Device which are not required
+(BOOL)deleteFromDeviceList:(int)pk {
	sqlite3 *database;
	BOOL retValue = NO;
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *tempSQL = [[NSString alloc] initWithFormat:@"Delete from DeviceList where PrimaryKey = '%i'", pk];
        const char *sqlStatement = [tempSQL cStringUsingEncoding:NSUTF8StringEncoding];
        [tempSQL release];

		sqlite3_stmt *compiledStatement;
		sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL);
		retValue = sqlite3_step(compiledStatement);
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return retValue;	
}
