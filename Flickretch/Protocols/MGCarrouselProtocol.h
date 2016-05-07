//
//  MGCarrouselProtocol.h
//  Flickretch
//
//  Created by Miguel Oliveira on 07/05/16.
//  Copyright © 2016 Miguel Oliveira. All rights reserved.
//

#ifndef MGCarrouselProtocol_h
#define MGCarrouselProtocol_h

@protocol MGCarrousel <NSObject>

- (id)itemNextTo:(id)item;

- (id)itemBefore:(id)item;

@end

#endif /* MGCarrouselProtocol_h */
