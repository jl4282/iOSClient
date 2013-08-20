//
//  Item.m
//  ARIS
//
//  Created by David Gagnon on 4/1/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Item.h"
#import "ItemViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Item

@synthesize itemId;
@synthesize name;
@synthesize idescription;
@synthesize itemType;
@synthesize mediaId;
@synthesize iconMediaId;
@synthesize qty;
@synthesize maxQty;
@synthesize weight;
@synthesize dropable;
@synthesize destroyable;
@synthesize tradeable;
@synthesize url;

- (Item *) init
{
    if(self = [super init])
    {
        self.itemId = 0;
        self.name = @"Item";
        self.idescription = @"Description";
        self.itemType = ItemTypeNormal;
        self.mediaId = 0;
        self.iconMediaId = 0;
        self.qty = 0;
        self.maxQty = 1;
        self.weight = 0;
        self.dropable = NO;
        self.destroyable = NO;
        self.tradeable = NO;
        self.url = @"";
    }
    return self;
}

- (Item *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.itemId       = [dict validIntForKey:@"item_id"];
        self.name         = [dict validObjectForKey:@"name"];
        self.idescription = [dict validObjectForKey:@"description"];
        if     ([[dict validStringForKey:@"type"] isEqualToString:@"NORMAL"]) self.itemType = ItemTypeNormal;
        else if([[dict validStringForKey:@"type"] isEqualToString:@"ATTRIB"]) self.itemType = ItemTypeAttribute;
        else if([[dict validStringForKey:@"type"] isEqualToString:@"URL"])    self.itemType = ItemTypeWebPage;
        self.mediaId      = [dict validIntForKey:@"media_id"];
        self.iconMediaId  = [dict validIntForKey:@"icon_media_id"];
        self.qty          = [dict validIntForKey:@"qty"];
        self.maxQty       = [dict validIntForKey:@"max_qty_in_inventory"];
        self.weight       = [dict validIntForKey:@"weight"];
        self.dropable     = [dict validBoolForKey:@"dropable"];
        self.destroyable  = [dict validBoolForKey:@"destroyable"];
        self.tradeable    = [dict validBoolForKey:@"tradeable"];
        self.url          = [dict validObjectForKey:@"url"];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectItem;
}

- (ItemViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate,StateControllerProtocol> *)d viewFrame:(CGRect)vf fromSource:(id)s
{
    if(self.qty == 0) self.qty = 1;
	return [[ItemViewController alloc] initWithItem:self viewFrame:vf delegate:d source:s];
}

-(Item *)copy
{
    Item *c = [[Item alloc] init];
    c.itemId = self.itemId;
    c.name = self.name;
    c.idescription = self.idescription;
    c.itemType = self.itemType;
    c.mediaId = self.mediaId;
    c.iconMediaId = self.iconMediaId;
    c.qty = self.qty;
    c.maxQty = self.maxQty;
    c.weight = self.weight;
    c.dropable = self.dropable;
    c.destroyable = self.destroyable;
    c.tradeable = self.tradeable;
    c.url = self.url;
    return c;
}

- (int)compareTo:(Item *)ob
{
	return (ob.itemId == self.itemId);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Item- Id:%d\tName:%@\tType:%u\tQty:%d",self.itemId,self.name,self.itemType,self.qty];
}

@end
