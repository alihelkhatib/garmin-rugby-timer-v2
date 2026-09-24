using Toybox.Test;

(:test)
function testLayoutFamiliesCoverValidatedProfiles(logger) {
    Test.assertEqual("MainLayoutInstinct", RugbyLayoutSupport.getLayoutId(RugbyLayoutSupport.getFamily(176, 176)));
    Test.assertEqual("MainLayoutCompactRound", RugbyLayoutSupport.getLayoutId(RugbyLayoutSupport.getFamily(240, 240)));
    Test.assertEqual("MainLayoutLargeRound", RugbyLayoutSupport.getLayoutId(RugbyLayoutSupport.getFamily(260, 260)));
    Test.assertEqual("MainLayoutRect", RugbyLayoutSupport.getLayoutId(RugbyLayoutSupport.getFamily(240, 280)));
    return true;
}
