/**
 * 본사가 동의서 공지를 게시하면 대상 가맹점마다 동의 대상 행을 만든다.
 *
 * 같은 공지로 발행을 두 번 눌러도 행이 두 번 생기면 안 되므로,
 * (공지, 가맹점) 조합이 이미 있으면 건너뛴다.
 * 공지 단위로 묶어 두기 때문에 다음 동의서를 게시해도 이전 이력과 섞이지 않는다.
 */
public with sharing class ConsentPublisher {

    public class ConsentTarget {
        public String noticeId;
        public String storeId;
        public String ownerKey;
        public Boolean isAgreed = false;
        public Date agreedDate;

        public ConsentTarget(String noticeId, String storeId, String ownerKey) {
            this.noticeId = noticeId;
            this.storeId = storeId;
            this.ownerKey = ownerKey;
        }

        public String key() {
            return noticeId + '|' + storeId;
        }
    }

    public class Store {
        public String storeId;
        public String ownerKey;
        public Boolean isOpen;

        public Store(String storeId, String ownerKey, Boolean isOpen) {
            this.storeId = storeId;
            this.ownerKey = ownerKey;
            this.isOpen = isOpen;
        }
    }

    /**
     * @param noticeId 게시한 동의서 공지
     * @param stores   대상 가맹점 (폐점 매장은 제외)
     * @param existing 이미 발행된 동의 대상
     * @return 새로 만들어야 하는 동의 대상만
     */
    public static List<ConsentTarget> publish(String noticeId, List<Store> stores, List<ConsentTarget> existing) {
        Set<String> publishedKeys = new Set<String>();
        for (ConsentTarget target : existing) {
            publishedKeys.add(target.key());
        }

        List<ConsentTarget> toCreate = new List<ConsentTarget>();
        for (Store store : stores) {
            if (!store.isOpen) {
                continue;
            }
            ConsentTarget target = new ConsentTarget(noticeId, store.storeId, store.ownerKey);
            if (publishedKeys.add(target.key())) {
                toCreate.add(target);
            }
        }
        return toCreate;
    }
}
