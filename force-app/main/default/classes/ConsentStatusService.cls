/**
 * 전자동의 현황: 동의율 집계, 미동의 가맹점 판별, 필터와 페이지 나눔.
 *
 * 동의율은 두 가지로 본다.
 *  - 가맹점 기준: 동의한 매장 수 / 전체 매장 수
 *  - 가맹점주 기준: 운영하는 매장을 모두 동의한 점주 수 / 전체 점주 수
 * 한 점주가 여러 매장을 운영하면 두 숫자가 달라지고, 현업은 둘 다 묻는다.
 */
public with sharing class ConsentStatusService {

    public class Row {
        public String storeId;
        public String ownerKey;
        public String region;
        public String team;
        public Boolean isAgreed;

        public Row(String storeId, String ownerKey, String region, String team, Boolean isAgreed) {
            this.storeId = storeId;
            this.ownerKey = ownerKey;
            this.region = region;
            this.team = team;
            this.isAgreed = isAgreed;
        }
    }

    public class Summary {
        public Integer storeTotal = 0;
        public Integer storeAgreed = 0;
        public Integer ownerTotal = 0;
        public Integer ownerAgreed = 0;

        public Decimal storeRate() {
            return rate(storeAgreed, storeTotal);
        }

        public Decimal ownerRate() {
            return rate(ownerAgreed, ownerTotal);
        }
    }

    public class ResultPage {
        public List<Row> rows = new List<Row>();
        public Integer pageNumber;
        public Integer totalPages;
        public Integer totalCount;
    }

    public static Summary summarize(List<Row> rows) {
        Summary summary = new Summary();
        Map<String, Boolean> ownerAllAgreed = new Map<String, Boolean>();
        for (Row row : rows) {
            summary.storeTotal++;
            if (row.isAgreed) {
                summary.storeAgreed++;
            }
            Boolean soFar = ownerAllAgreed.containsKey(row.ownerKey) ? ownerAllAgreed.get(row.ownerKey) : true;
            ownerAllAgreed.put(row.ownerKey, soFar && row.isAgreed);
        }
        summary.ownerTotal = ownerAllAgreed.size();
        for (Boolean allAgreed : ownerAllAgreed.values()) {
            if (allAgreed) {
                summary.ownerAgreed++;
            }
        }
        return summary;
    }

    /**
     * 지역 · 팀 필터. 빈 값이면 해당 조건은 걸지 않는다.
     */
    public static List<Row> filter(List<Row> rows, String region, String team, Boolean onlyMissing) {
        List<Row> result = new List<Row>();
        for (Row row : rows) {
            if (String.isNotBlank(region) && row.region != region) {
                continue;
            }
            if (String.isNotBlank(team) && row.team != team) {
                continue;
            }
            if (onlyMissing == true && row.isAgreed) {
                continue;
            }
            result.add(row);
        }
        return result;
    }

    /**
     * @param pageNumber 1부터 시작. 범위를 넘으면 마지막 페이지를 돌려준다.
     */
    public static ResultPage paginate(List<Row> rows, Integer pageNumber, Integer pageSize) {
        ResultPage page = new ResultPage();
        page.totalCount = rows.size();
        page.totalPages = Math.max(1, (Integer) Math.ceil(rows.size() / (Decimal) pageSize));
        page.pageNumber = Math.min(Math.max(1, pageNumber), page.totalPages);

        Integer startIndex = (page.pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, rows.size());
        for (Integer i = startIndex; i < endIndex; i++) {
            page.rows.add(rows[i]);
        }
        return page;
    }

    private static Decimal rate(Integer part, Integer total) {
        return total == 0 ? 0 : (part * 100.0 / total).setScale(1);
    }
}
