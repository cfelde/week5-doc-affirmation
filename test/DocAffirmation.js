const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("DocAff", function () {
    describe("Basics", function () {
        async function deployTokenFixture() {
            const DocAff = await ethers.getContractFactory("DocAffirmation");
            const docAff = await DocAff.deploy();

            await docAff.deployed();

            return docAff;
        }

        it("Run through", async function() {
            const docAff = await loadFixture(deployTokenFixture);

            await docAff.createDocumentEntry();
            await docAff.addDocumentToEntry(0, 10);
            await docAff.addDocumentToEntry(0, 20);
            await docAff.addDocumentToEntry(0, 30);

            await docAff.removeDocumentToEntry(0, 20, 1);

            console.log("------");

            // BigNumber { value: "30" }
            console.log(await docAff.tokenDocuments(0, 1));

            // BigNumber { value: "4" }
            console.log(await docAff.tokenVersion(0));

            const [, docViewer, docSigner] = await ethers.getSigners();

            await docAff.setViewer(0, docViewer.address);
            await docAff.setSigner(0, docSigner.address);

            console.log("------");

            // true
            console.log(await docAff.tokenViewers(0, docViewer.address));
            // false
            console.log(await docAff.tokenViewers(0, docSigner.address));

            console.log("------");

            // false
            console.log(await docAff.tokenSigners(0, docViewer.address));
            // true
            console.log(await docAff.tokenSigners(0, docSigner.address));

            console.log("------");

            // true
            console.log(await docAff.canView(0, docViewer.address));
            // false
            console.log(await docAff.canSign(0, docViewer.address));

            console.log("------");

            // true
            console.log(await docAff.canView(0, docSigner.address));
            // false
            console.log(await docAff.canSign(0, docSigner.address));

            console.log("------");

            await docAff.connect(docSigner).sign(0, 4);
            await docAff.connect(docSigner).reject(0, 4);
        });
    });
});