load("cache.star", "cache")
load("encoding/base64.star", "base64")
load("http.star", "http")
load("render.star", "render")

CIRCLECI_LOGO = base64.decode("""
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
""")
CIRCLECI_TOKEN = ""
CIRCLECI_PIPELINE_API_URL = "https://circleci.com/api/v2/project/gh/loadsmart/django-jaiminho/pipeline/364" #success 377, failure 364
CIRCLECI_WORKFLOWS_API_URL = "https://circleci.com/api/v2/pipeline/{}/workflow"

def main():
    cached_pipeline = cache.get("circleci_pipeline")
    if cached_pipeline != None:
        print("[Cache] Hit")
        pipeline = cached_pipeline
    else:
        print("[Cache] Miss")
        response = http.get(CIRCLECI_PIPELINE_API_URL, params={"circle-token": CIRCLECI_TOKEN})
        if response.status_code != 200:
            fail("Can't fetch pipeline from CircleCI", response.status_code)
        pipeline = response.json()
        # cache.set("circleci_pipeline", pipeline, ttl_seconds=60)
        print("[CircleCI]", "Pipeline", pipeline)

        response2 = http.get(CIRCLECI_WORKFLOWS_API_URL.format(pipeline["id"]), params={"circle-token": CIRCLECI_TOKEN})
        workflows = response2.json()
        print("[CircleCI]", "Workflows", workflows)
        statuses = [item["status"] for item in workflows["items"]]
        print("[CircleCI]", "Statuses", statuses)

    success = "failed" not in statuses

    return render.Root(
        child = render.Box(
            child = render.Row(
                expanded=True,
                main_align="space_evenly",
                cross_align="center",
                children = [
                    render.Image(src=CIRCLECI_LOGO, width=16, height=16),
                    render.Text("CircleCI", color="#0f0" if success else "#f00")
                ]
            )
        )
    )
