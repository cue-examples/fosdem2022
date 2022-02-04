package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"

	pb "acme.com/x/quote"
	"google.golang.org/grpc"
)

var (
	port = flag.Int("port", 3000, "The server port")
)

func main() {
	log.SetFlags(0)
	log.Println("in quoteserver")
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterQuoterServer(s, &server{})
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

type server struct {
	pb.UnimplementedQuoterServer
}

func (s *server) Quote(ctx context.Context, in *pb.QuoteRequest) (*pb.QuoteResponse, error) {
	log.Printf("Received: %#v", in)
	return &pb.QuoteResponse{Quotes: []string{"Concurrency is not parallelism."}}, nil
}
