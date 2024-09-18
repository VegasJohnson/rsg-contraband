local Translations = {
    title = {
        drugs = 'Contraband Selling',
    },
    error = {
        blacklist = 'Cannot sell here.',
        stopped = 'Stopped selling drugs!',
        empty = 'No more contraband to sell!',
        notwant = 'Person not interested!',
        rob = 'You have been robbed!',
        decline = 'Offer Declined',
        nolaw = 'Not enough lawmen OR Bad Luck!',
    },
    sell = {
        item = 'Sell '
    },
    success = {
        selling = 'Started selling drugs!'
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
----