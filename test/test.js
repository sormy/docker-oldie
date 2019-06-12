const { Builder, By, Key, until } = require('selenium-webdriver');

(async function example() {
  let driver = await new Builder()
    .forBrowser('internet explorer')
    .usingServer('http://localhost:5555/wd/hub')
    .build();

  try {
    await driver.get('http://www.google.com/ncr');
    await driver.findElement(By.name('q')).sendKeys('webdriver', Key.RETURN);
    await driver.wait(until.titleIs('webdriver - Google Search'), 5000);
  } finally {
    await driver.quit();
  }
})();
