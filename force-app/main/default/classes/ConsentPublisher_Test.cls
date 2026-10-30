@IsTest
private class ConsentPublisher_Test {

    @IsTest
    static void createsOneTargetPerOpenStore() {
        List<ConsentPublisher.Store> stores = new List<ConsentPublisher.Store>{
            new ConsentPublisher.Store('S1', 'OWNER-A', true),
            new ConsentPublisher.Store('S2', 'OWNER-A', true),
            new ConsentPublisher.Store('S3', 'OWNER-B', false)
        };

        List<ConsentPublisher.ConsentTarget> created = ConsentPublisher.publish('NOTICE-1', stores, new List<ConsentPublisher.ConsentTarget>());

        Assert.areEqual(2, created.size());
        Assert.areEqual('NOTICE-1', created[0].noticeId);
        Assert.isFalse(created[0].isAgreed);
    }

    @IsTest
    static void publishingTwiceDoesNotDuplicate() {
        List<ConsentPublisher.Store> stores = new List<ConsentPublisher.Store>{
            new ConsentPublisher.Store('S1', 'OWNER-A', true),
            new ConsentPublisher.Store('S1', 'OWNER-A', true)
        };
        List<ConsentPublisher.ConsentTarget> first = ConsentPublisher.publish('NOTICE-1', stores, new List<ConsentPublisher.ConsentTarget>());
        List<ConsentPublisher.ConsentTarget> second = ConsentPublisher.publish('NOTICE-1', stores, first);

        Assert.areEqual(1, first.size());
        Assert.isTrue(second.isEmpty());
    }

    @IsTest
    static void newNoticeKeepsPreviousHistorySeparate() {
        List<ConsentPublisher.Store> stores = new List<ConsentPublisher.Store>{ new ConsentPublisher.Store('S1', 'OWNER-A', true) };
        List<ConsentPublisher.ConsentTarget> previous = ConsentPublisher.publish('NOTICE-1', stores, new List<ConsentPublisher.ConsentTarget>());
        previous[0].isAgreed = true;

        List<ConsentPublisher.ConsentTarget> next = ConsentPublisher.publish('NOTICE-2', stores, previous);

        Assert.areEqual(1, next.size());
        Assert.isFalse(next[0].isAgreed);
        Assert.isTrue(previous[0].isAgreed);
    }

    @IsTest
    static void publishesToManyStores() {
        List<ConsentPublisher.Store> stores = new List<ConsentPublisher.Store>();
        for (Integer i = 0; i < 1000; i++) {
            stores.add(new ConsentPublisher.Store('S' + i, 'OWNER-' + Math.mod(i, 300), true));
        }
        Test.startTest();
        List<ConsentPublisher.ConsentTarget> created = ConsentPublisher.publish('NOTICE-1', stores, new List<ConsentPublisher.ConsentTarget>());
        Test.stopTest();
        Assert.areEqual(1000, created.size());
    }
}
