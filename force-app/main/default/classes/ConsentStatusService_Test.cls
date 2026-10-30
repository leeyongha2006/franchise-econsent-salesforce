@IsTest
private class ConsentStatusService_Test {

    private static List<ConsentStatusService.Row> rows() {
        return new List<ConsentStatusService.Row>{
            // 점주 A: 매장 3개 중 2개만 동의 → 점주 기준으로는 미동의
            new ConsentStatusService.Row('S1', 'OWNER-A', 'Seoul', 'Team1', true),
            new ConsentStatusService.Row('S2', 'OWNER-A', 'Seoul', 'Team1', true),
            new ConsentStatusService.Row('S3', 'OWNER-A', 'Busan', 'Team2', false),
            // 점주 B: 매장 1개 동의
            new ConsentStatusService.Row('S4', 'OWNER-B', 'Seoul', 'Team2', true)
        };
    }

    @IsTest
    static void storeAndOwnerRatesDiffer() {
        ConsentStatusService.Summary summary = ConsentStatusService.summarize(rows());

        Assert.areEqual(4, summary.storeTotal);
        Assert.areEqual(3, summary.storeAgreed);
        Assert.areEqual(75.0, summary.storeRate());

        Assert.areEqual(2, summary.ownerTotal);
        Assert.areEqual(1, summary.ownerAgreed);
        Assert.areEqual(50.0, summary.ownerRate());
    }

    @IsTest
    static void emptyListHasZeroRate() {
        ConsentStatusService.Summary summary = ConsentStatusService.summarize(new List<ConsentStatusService.Row>());
        Assert.areEqual(0, summary.storeRate());
        Assert.areEqual(0, summary.ownerRate());
    }

    @IsTest
    static void filtersByRegionTeamAndMissing() {
        Assert.areEqual(3, ConsentStatusService.filter(rows(), 'Seoul', null, false).size());
        Assert.areEqual(1, ConsentStatusService.filter(rows(), 'Seoul', 'Team2', false).size());

        List<ConsentStatusService.Row> missing = ConsentStatusService.filter(rows(), null, null, true);
        Assert.areEqual(1, missing.size());
        Assert.areEqual('S3', missing[0].storeId);
    }

    @IsTest
    static void paginatesAndClampsPageNumber() {
        List<ConsentStatusService.Row> many = new List<ConsentStatusService.Row>();
        for (Integer i = 0; i < 205; i++) {
            many.add(new ConsentStatusService.Row('S' + i, 'OWNER-' + i, 'Seoul', 'Team1', Math.mod(i, 2) == 0));
        }

        ConsentStatusService.ResultPage page = ConsentStatusService.paginate(many, 3, 100);
        Assert.areEqual(3, page.totalPages);
        Assert.areEqual(5, page.rows.size());
        Assert.areEqual('S200', page.rows[0].storeId);

        Assert.areEqual(3, ConsentStatusService.paginate(many, 99, 100).pageNumber);
        Assert.areEqual(1, ConsentStatusService.paginate(new List<ConsentStatusService.Row>(), 1, 100).totalPages);
    }
}
