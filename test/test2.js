const { writeFileSync } = require('fs');
const { Builder, By, Key, until } = require('selenium-webdriver');

(async function example() {
  const driver = await new Builder()
    .forBrowser('internet explorer')
    .usingServer('http://localhost:5555/wd/hub')
    .build();

  try {
    await driver.get('http://rutor.info');
    const base64 = await driver.takeScreenshot();
    const buffer = Buffer.from(base64, 'base64');
    writeFileSync("screenshot.png", buffer);
    await driver.findElement(By.name('search')).sendKeys('webdriver', Key.RETURN);
    await driver.wait(until.urlMatches(/\/search\/webdriver$/), 5000);
  } finally {
    await driver.quit();
  }
})();
