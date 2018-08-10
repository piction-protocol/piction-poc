const forEachAsync = async (array, func) => {
    await new Promise(resolve => {
        Array.from(array).forEach( async (item, i) => {
            await func(item, i);

            if (array.length - 1 == i) {
                resolve();
            }
        });
    });
};
exports.forEachAsync = forEachAsync;
