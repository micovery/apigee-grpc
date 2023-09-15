// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"crypto/tls"
	"fmt"
	"github.com/micovery/apigee-grpc/pkg/greeter"
	"github.com/micovery/apigee-grpc/pkg/greeter/generated/pb"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"net"
	"os"
)

func main() {
	var lis net.Listener
	var err error

	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "443"
	}

	key := os.Getenv("TLS_KEY_FILE")
	cert := os.Getenv("TLS_CERT_FILE")

	cer, err := tls.LoadX509KeyPair(cert, key)
	if err != nil {
		panic(fmt.Errorf("could not load TLS Key/Cert. %s", err.Error()))
		return
	}

	config := &tls.Config{
		NextProtos:   []string{"h2"},
		Certificates: []tls.Certificate{cer},
	}

	if lis, err = tls.Listen("tcp", fmt.Sprintf(":%s", port), config); err != nil {
		panic(fmt.Errorf("could not start gRPC server on port %s. %s", port, err.Error()))
	}

	//goland:noinspection GoUnhandledErrorResult
	defer lis.Close()

	grpcServer := grpc.NewServer([]grpc.ServerOption{}...)
	reflection.Register(grpcServer)
	pb.RegisterGreeterServer(grpcServer, &greeter.GRPCServer{})

	fmt.Printf("Starting TLS gRPC server on port %s\n", port)
	//goland:noinspection GoUnhandledErrorResult
	grpcServer.Serve(lis)
}
