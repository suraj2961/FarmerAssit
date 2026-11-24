# FarmerAssist backend

Spring Boot API that fetches mandi (market) prices from the data.gov.in
Agmarknet dataset and serves them to the FarmerAssist Flutter app. Keeps
the API key server-side and caches responses for 24 hours since the
source data only updates once a day.

## Setup

1. Get a free API key from https://data.gov.in — register, then go to
   "My Account" → "API Keys", and request access to the "Variety-wise
   Daily Market Prices" (Agmarknet) resource.

2. Set it as an environment variable (don't hardcode it anywhere):

   ```bash
   export AGMARKNET_API_KEY=your_real_key_here
   ```

3. Run the app:

   ```bash
   ./mvnw spring-boot:run
   ```

   The API starts on `http://localhost:8080`.

## Endpoint

```
GET /api/mandi-prices
```

Query params (all optional):

| Param      | Type   | Default | Notes                          |
|------------|--------|---------|---------------------------------|
| state      | string | -       | e.g. `Karnataka`                |
| district   | string | -       | e.g. `Mangalore`                |
| commodity  | string | -       | e.g. `Tomato`                   |
| limit      | int    | 100     | 1-500                           |
| offset     | int    | 0       | for pagination                  |

Example:

```
GET /api/mandi-prices?state=Karnataka&district=Mangalore&commodity=Tomato
```

Response shape matches the Flutter `MandiPrice` model exactly — no
mapping needed on the client:

```json
[
  {
    "state": "Karnataka",
    "district": "Mangalore",
    "market": "Mangalore",
    "commodity": "Tomato",
    "variety": "Local",
    "grade": "FAQ",
    "arrival_date": "27/07/2026",
    "min_price": 1200.0,
    "max_price": 1800.0,
    "modal_price": 1500.0
  }
]
```

## Project layout

```
controller/   REST endpoints
service/      Business logic + caching
client/       Talks to data.gov.in (holds the API key)
dto/          Clean response objects returned to the Flutter app
config/       Cache configuration
exception/    Custom exceptions + global error handler
```

## Next steps (not yet built)

- Weather alerts endpoint
- Crop sell advisory logic
- Government schemes endpoint
- News/videos feed
