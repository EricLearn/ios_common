
#import "PredictScrollView.h"


@implementation PredictScrollView
@synthesize pages=_pages;
@synthesize currentPage=_itemPage;
@synthesize numberOfPages=_numberOfPages;
@synthesize delegate2=_delegate2;


#pragma mark Generic methods

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	//frame.origin.x = -5;
	//frame.size.width += 10;
	self = [super initWithFrame:frame];
	self.pagingEnabled = YES;
	self.delegate = self;
	//self.backgroundColor = [UIColor blackColor];

	return self;
}

// Destructor
- (void)dealloc
{
	if (_pages) free(_pages);
}

//
- (void)removeFromSuperview
{
	_delegate2 = nil;
	[super removeFromSuperview];
}

// Remove cached pages
- (void)freePages:(BOOL)force
{	
    
	NSUInteger count = _numberOfPages;
	for (NSUInteger i = 0; i < count; ++i)
	{
		if (_pages[i]) 
		{
			if ((i != _itemPage) && (force || ((i != _itemPage - 1) && (i != _itemPage + 1))))
			{
				[_pages[i] removeFromSuperview];
				_pages[i] = nil;
			}
		}
	}
}

//
- (void)loadPage:(NSUInteger)index
{	
	if (index >= _numberOfPages) return;
	if (_pages[index]) return;

	CGRect frame = self.frame;
	frame.origin.y = 0;
	frame.origin.x = frame.size.width * index + 0;
	

	_pages[index] = [_delegate2 scrollView:self viewForPage:index inFrame:frame];
	_pages[index].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:_pages[index]];
}

//
- (void)loadNearby
{
    @autoreleasepool {
        [self loadPage:_itemPage - 1];
        [self loadPage:_itemPage + 1];
    }
}

//
- (void)scheduledNearby
{	
    @autoreleasepool {
        [self performSelectorOnMainThread:@selector(loadNearby) withObject:nil waitUntilDone:YES];
    }
}

//
- (void)loadPages
{	
	[self freePages:NO];
	[self loadPage:_itemPage];
	[_delegate2 scrollView:self scrollToPage:_itemPage];

	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scheduledNearby) userInfo:nil repeats:NO];
}

//
- (void)setCurrentPage:(NSUInteger)currentPage
{	
	if (currentPage >= _numberOfPages)
	{
		currentPage = 0;
	}
   
	if (_itemPage != currentPage)
	{
		self.contentOffset = CGPointMake(self.frame.size.width * currentPage, 0);
	}
	else
	{
		[self loadPages];
	}
}

//
- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
	if (_numberOfPages) [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	_numberOfPages = numberOfPages;
	
	NSUInteger size = numberOfPages * sizeof(UIView *);
	_pages = (UIView * __autoreleasing* )realloc(_pages, size);
	memset(_pages, 0, size);
}


#pragma mark View methods

// Layout subviews.
- (void)layoutSubviews
{	
	_bIgnore = YES;
	[super layoutSubviews];
	self.contentSize = CGSizeMake(self.frame.size.width * _numberOfPages, self.frame.size.height);
	_bIgnore = NO;
}

// Set view frame.
- (void)setFrame:(CGRect)frame
{	
	_bIgnore = YES;
	[super setFrame:frame];
	self.contentOffset = CGPointMake(frame.size.width * _itemPage, 0);
	_bIgnore = NO;
}


#pragma mark Scroll view methods

//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (_bIgnore) return;

	CGFloat width = scrollView.frame.size.width;
	NSUInteger currentPage = floor((scrollView.contentOffset.x - width*3 / 4) / width) + 1;
    
	if ((_itemPage != currentPage) && (currentPage < _numberOfPages))
	{
		_itemPage = currentPage;
		[self loadPages];
	}
}

@end

@implementation AutoScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
    }
    return self;
}

- (void)setTime:(NSTimeInterval)time
{
    _time = time;
    if (_time > 0.1)
    {
        [_timer invalidate];
        _timer = nil;
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)setCurrentPageAnimated:(NSUInteger)currentPage
{
    if (currentPage >= _numberOfPages)
    {
        currentPage = 0;
    }
    
    if (_itemPage != currentPage)
    {
        [self setContentOffset:CGPointMake(self.frame.size.width * currentPage, 0) animated:YES];
    }
    else
    {
        [self loadPages];
    }
}

- (void)removeFromSuperview
{
    [_timer invalidate];
    _timer = nil;
    [super removeFromSuperview];
}

- (void)autoScroll
{
    if (self.numberOfPages > 1 && self.dragging == NO)
    {
        NSUInteger page = (self.currentPage+1)%self.numberOfPages;
        [self setCurrentPageAnimated:page];
    }
}

- (void)freePages:(BOOL)force
{
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self reStartTimer];
}

- (void)pauseTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)reStartTimer
{
    self.time = _time;
}

@end

@implementation RecycleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _predictView = [[AutoScrollView alloc] initWithFrame:self.bounds];
        _predictView.delegate2 = self;
        _predictView.time = 4;
        [self addSubview:_predictView];
    }
    return self;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    if (numberOfPages > 1)
    {
        numberOfPages += 2;
    }
    _predictView.numberOfPages = numberOfPages;
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
    _currentPage = currentPage;
    if (_numberOfPages > 1)
    {
        if (currentPage == 0)
        {
            currentPage = 1;
        }
        else if(currentPage == _numberOfPages - 1)
        {
            currentPage = _numberOfPages + 1;
        }
    }
    _predictView.currentPage = currentPage;
}

- (UIView *)scrollView:(PredictScrollView *)scrollView viewForPage:(NSUInteger)index inFrame:(CGRect)frame
{
    if (_numberOfPages > 1)
    {
        if (index == 0)
        {
            index = _numberOfPages - 1;
        }
        else if(index == _predictView.numberOfPages - 1)
        {
            index = 0;
        }
        else
        {
            index--;
        }
        return [_delegate scrollView:scrollView viewForPage:index inFrame:frame];
    }
    else
    {
        return [_delegate scrollView:scrollView viewForPage:index inFrame:frame];
    }
    return nil;
    
}

- (void)scrollView:(PredictScrollView *)scrollView scrollToPage:(NSUInteger)index
{
    if (_numberOfPages > 1)
    {
        if (index == 0 || index == _predictView.numberOfPages - 1)
        {
            if (index == 0)
            {
                index = _predictView.numberOfPages - 2;
            }
            else if(index == _predictView.numberOfPages - 1)
            {
                index = 1;
            }
            _predictView.userInteractionEnabled = NO;
            [self performSelector:@selector(setPage:) withObject:@(index) afterDelay:0.1];
        }
        else
        {
            [_delegate scrollView:scrollView scrollToPage:index - 1];
        }
        
    }
    else
    {
        [_delegate scrollView:scrollView scrollToPage:index];
    }
}

- (void)setPage:(NSNumber *)page
{
    _predictView.userInteractionEnabled = YES;
    _predictView.currentPage = [page intValue];
}

- (void)pauseTimer
{
    [_predictView pauseTimer];
}

- (void)reStartTimer
{
    [_predictView reStartTimer];
}
@end


//
@implementation PageControlScrollView
@synthesize pageCtrl=_pageCtrl;

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	frame.origin.x = frame.size.width - 100;
	frame.size.width = 100;
	frame.origin.y = CGRectGetMaxY(self.frame) - 20;
	frame.size.height = 10;
	_pageCtrl = [[UIPageControl alloc] initWithFrame:frame];
	_pageCtrl.numberOfPages = 0;
	_pageCtrl.currentPage = 0;
	_pageCtrl.hidesForSinglePage = YES;
    _pageCtrl.userInteractionEnabled = NO;
	[_pageCtrl addTarget:self action:@selector(setCurrentPage) forControlEvents:UIControlEventValueChanged];

	return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _pageCtrl.frame;
    frame.origin.x = (CGRectGetWidth(self.frame) - frame.size.width)/2;
    frame.origin.y = CGRectGetMaxY(self.frame) - 20;
	_pageCtrl.frame = frame;
}
//
- (void) updateDots
{
    /*{
        UIImage *imageRedDot = [UIImage imageNamed:@"RedDot.png"];
        UIImage *imageBlueDot = [UIImage imageNamed:@"BlueDot.png"];
        
		NSArray *subView = _pageCtrl.subviews;
		
		for (NSInteger i = 0; i < [subView count]; i++) {
			UIImageView *dot = [subView objectAtIndex:i];
            dot.image = (_pageCtrl.currentPage == i ? imageRedDot : imageBlueDot);
		}
	}*/
}


//
- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if (_hasParent)
	{
		[_pageCtrl removeFromSuperview];
		_hasParent = NO;
	}
}

//
- (void)didMoveToSuperview
{
	if (self.superview)
	{
		_hasParent = YES;
		[self.superview addSubview:_pageCtrl];
	}
}

//
- (void)setNumberOfPages:(NSUInteger)count
{
	[super setNumberOfPages:count];
	_pageCtrl.numberOfPages = count;
    [self updateDots];
}

//
- (void)loadPages
{
	[super loadPages];
	_pageCtrl.currentPage = self.currentPage;
    [self updateDots];
}

//
- (void)setCurrentPage
{
	self.currentPage = _pageCtrl.currentPage;
    [self updateDots];
}

@end

