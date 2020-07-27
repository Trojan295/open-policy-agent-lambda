package main

import (
	"bytes"
	"context"
	"encoding/json"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/open-policy-agent/opa/rego"
)

type Request events.APIGatewayProxyRequest
type Response events.APIGatewayProxyResponse

var regoModules func(*rego.Rego)

func Handler(ctx context.Context, request Request) (Response, error) {
	queryString := request.QueryStringParameters["query"]

	var input interface{}
	if err := json.Unmarshal([]byte(request.Body), &input); err != nil {
		return Response{
			StatusCode: 400,
			Body:       "this is bullshit",
		}, nil
	}

	query, err := rego.New(
		rego.Query(queryString),
		regoModules,
	).PrepareForEval(ctx)
	if err != nil {
		return Response{StatusCode: 400, Body: err.Error()}, nil
	}

	result, err := query.Eval(ctx, rego.EvalInput(input))
	if err != nil {
		return Response{StatusCode: 400}, nil
	}

	var buf bytes.Buffer

	body, err := json.Marshal(result)
	if err != nil {
		return Response{StatusCode: 404}, nil
	}
	json.HTMLEscape(&buf, body)

	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Body:            buf.String(),
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}

	return resp, nil
}

func init() {
	regoModules = rego.Load([]string{"opa"}, nil)

}

func main() {
	lambda.Start(Handler)
}
