package main

import (
	"context"
	"flag"
	"log"
	"strings"
	"time"

	pb "acme.com/x/quote"
	"github.com/rogpeppe/retry"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var (
	fRequote = flag.String("requote", "10s", "how often to requote")
	fAddr    = flag.String("addr", "localhost:3000", "the address to connect to")
)

func main() {
	log.SetFlags(0)
	log.Println("in funquoter")
	flag.Parse()

	requote, err := time.ParseDuration(*fRequote)
	if err != nil {
		log.Fatalf("failed to parse requote duration %q: %v", *fRequote, err)
	}

	var client pb.QuoterClient

	for {
		if client == nil {
			var retryStrategy = retry.Strategy{
				Delay:       100 * time.Millisecond,
				MaxDelay:    5 * time.Second,
				MaxDuration: 30 * time.Second,
				Factor:      5,
			}
			var conn *grpc.ClientConn
			for i := retryStrategy.Start(nil); i.Next(); {
				conn, err = grpc.Dial(*fAddr,
					grpc.WithTransportCredentials(insecure.NewCredentials()),
					grpc.WithReturnConnectionError(),
					grpc.WithTimeout(time.Second),
				)
				if err == nil {
					break
				}
				// log.Printf("error: failed to connect to %s\n", *fAddr)
			}
			if err != nil {
				log.Fatalf("error: failed to connect to server %s: %v\n", *fAddr, err)
			}
			client = pb.NewQuoterClient(conn)
		}
		r, err := client.Quote(context.Background(), &pb.QuoteRequest{Lang: pb.Language_EN, Num: 1})
		if err != nil {
			client = nil
			log.Printf("error: failed to get quotes: %v", err)
			continue
		}
		log.Printf(`quotes: ["%v"]`, strings.Join(r.Quotes, `", "`))
		time.Sleep(requote)
	}
}
