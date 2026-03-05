import XCTest
import Combine
@testable import Cryospin

final class ESP32ServiceTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        TestURLProtocol.requestHandler = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testTurnOnFanUpdatesStateAfterSuccessfulRequest() {
        let service = makeService { request in
            XCTAssertEqual(request.url?.path, "/api/on")
            return (self.makeResponse(for: request, statusCode: 200), nil)
        }

        let expectation = expectation(description: "Fan state updated")

        service.$isFanOn
            .dropFirst()
            .sink { isOn in
                if isOn {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        service.turnOnFan()

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(service.lastRequestStatus, "Ventilateur active")
    }

    func testUpdateConfigurationRejectsInvalidTemperatureRange() {
        let service = makeService { _ in
            XCTFail("No network request should be sent for invalid configuration")
            throw URLError(.badServerResponse)
        }

        service.updateConfiguration(
            minTemp: 40,
            maxTemp: 35,
            fanPower: 50,
            durationMinutes: 5
        )

        XCTAssertEqual(
            service.lastRequestStatus,
            "La temperature minimale doit etre inferieure ou egale a la temperature maximale"
        )
    }

    func testRefreshStatusUpdatesPublishedValues() {
        let payload = #"{"isOn":true,"bodyTemperature":36.8}"#.data(using: .utf8)
        let service = makeService { request in
            XCTAssertEqual(request.url?.path, "/api/status")
            return (self.makeResponse(for: request, statusCode: 200), payload)
        }

        let expectation = expectation(description: "Device state refreshed")

        service.$bodyTemperature
            .dropFirst()
            .sink { value in
                if value == 36.8 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        service.refreshStatus()

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(service.isFanOn)
        XCTAssertEqual(service.lastReadStatus, "Etat recu")
    }

    private func makeService(
        handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data?)
    ) -> ESP32Service {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [TestURLProtocol.self]

        TestURLProtocol.requestHandler = handler

        let session = URLSession(configuration: configuration)
        return ESP32Service(baseURL: "http://192.168.4.1", session: session, pollingInterval: 60)
    }

    private func makeResponse(for request: URLRequest, statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: try! XCTUnwrap(request.url),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
